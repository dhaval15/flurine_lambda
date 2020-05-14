import 'dart:async';
import 'dart:isolate';

import '../lambda/handlers/handlers.dart';
import 'flow.dart';

class Vein {
  static Vein instance;
  final Isolate _isolate;
  final SendPort _sendPort;
  final ReceivePort _receivePort;
  final List<SubVein> _veins = [];

  Vein(this._isolate, this._sendPort, this._receivePort);

  Future<SubVein> createSubVein() async {
    ReceivePort receivePort = ReceivePort();
    _sendPort.send(receivePort.sendPort);
    Completer<SendPort> completer = Completer();
    SubVein subVein = SubVein(receivePort);
    receivePort.listen((result) {
      if (result is SendPort)
        completer.complete(result);
      else
        subVein._onResult(result);
    });
    subVein._sendPort = await completer.future;
    _veins.add(subVein);
    return subVein;
  }

  static Future init() async {
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(_compute, receivePort.sendPort);
    Completer<SendPort> _completer = Completer();
    receivePort.listen((message) {
      if (message is SendPort)
        _completer.complete(message);
    });
    instance = Vein(isolate, await _completer.future, receivePort);
  }

  static void _compute(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen(_computeListen);
  }

  static void _computeListen(message) {
    if (message is SendPort) {
      _Wrapper wrapper = _Wrapper();
      ReceivePort receivePort = ReceivePort();
      message.send(receivePort.sendPort);
      receivePort.listen((action) {
        SubVein._onAction(wrapper,message, receivePort, action);
      });
    }
  }

  void kill(){
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
    _veins.forEach((vein){
      vein.kill();
    });
  }

}

class _Wrapper{
  Timer _timer;
}

class SubVein extends Flow{
  SendPort _sendPort;
  ReceivePort _receivePort;

  static void _onAction(
      _Wrapper wrapper,
    SendPort sendPort,
    ReceivePort receivePort,
    _Action action,
  ) async {
    if (action is _KillAction) {
      wrapper._timer?.cancel();
      receivePort.close();
    }
    else if(action is _RunAction) {
      wrapper._timer?.cancel();
      if(action.handler.repeatingDuration!=null){
        wrapper._timer = Timer.periodic(action.handler.repeatingDuration,(t)async{
          sendPort.send(await action.handler.compute());
        });
      }
      else{
        sendPort.send(await action.handler.compute());
      }
    }
    else if(action is _ResetAction){
      wrapper._timer?.cancel();
    }
  }

  void kill() {
    _receivePort.close();
    _sendPort.send(_KillAction());
  }

  SubVein(this._receivePort);

  void run(Handler handler)async{
    if(handler is ConstHandler) {
      reset();
      _onResult(await handler.compute());
    }
    else
      _sendPort.send(_RunAction(handler));
  }

  void reset(){
    _sendPort.send(_ResetAction());
  }

  void _onResult(result) {
    add(result);
  }
}

mixin _Action {}

class _KillAction with _Action {}

class _RunAction with _Action {
  final Handler handler;

  _RunAction(this.handler);
}

class _ResetAction with _Action {

}
