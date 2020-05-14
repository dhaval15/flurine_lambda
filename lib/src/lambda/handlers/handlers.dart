import 'dart:async';

typedef HandlerBuilder = Handler Function();

abstract class Handler {
  static final Map<String, HandlerBuilder> _handlers = Map();

  static List<String> get types => _handlers.keys.toList();

  static void register(String type, HandlerBuilder handler) {
    _handlers[type] = handler;
  }

  static void registerMany(Map<String,HandlerBuilder> map){
    _handlers.addAll(map);
  }

  static Handler builder(String type) => _handlers[type]();

  Duration get repeatingDuration;
  Future compute();

  List params;
}

class ConstHandler extends Handler {
  ConstHandler();

  @override
  Future compute() async {
    return params[0];
  }

  @override
  String toString() => params[0];

  @override
  Duration get repeatingDuration => null;
}
