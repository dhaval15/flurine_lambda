import 'package:lambda/flurine_lambda.dart';

const TIME = 'tm';
const CONCAT = 'cc';

void main() async {
  Handler.registerMany({
    CONST: () => ConstHandler(),
    TIME: () => TimeHandler(),
    CONCAT: () => ConcatHandler(),
  });
  await Vein.init();
  final lambda = Lambda.parse('\$tm(2)\$');
  await lambda.execute();
  lambda.vein.listen(onData);
}

void onData(data) {
  print(data);
}

class TimeHandler extends Handler {

  @override
  Future compute() async {
    return DateTime.now().second;
  }

  @override
  Duration get repeatingDuration => Duration(seconds:params.last);
}

class CounterHandler extends Handler {

  @override
  Duration get repeatingDuration => null;

  int begin, end, step,current;

  @override
  set params(List params) {
    this.params = params;
    begin = params[0];
    end = params[1];
    step = params[2];
    current = params[3];
  }

  @override
  Future compute() async {
    if (current == null || current > end) current = begin;
    // ignore: omit_local_variable_types
    int temp = current;
    current = current + step;
    return temp;
  }
}

class ConcatHandler extends Handler{

  @override
  Duration get repeatingDuration => null;

  @override
  Future compute() async{
    return params.join();
  }

}
