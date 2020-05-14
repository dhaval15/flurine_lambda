import 'package:petitparser/petitparser.dart';
import '../lambda.dart';
import 'lambda_defination.dart';

class LambdaParser extends GrammarParser {
  LambdaParser() : super(LambdaParserDefinition());
}

class LambdaParserDefinition extends LambdaGrammarDefinition {
  @override
  Parser func() =>
      super.func().map((list) => Lambda.fromParsedString(list[0], list[1][1].cast<Lambda>()));

  @override
  Parser function() => super.function().map((list) => list[1]);

  @override
  Parser stringToken() => super
      .stringToken()
      .map((s) => Lambda.value(s.substring(1, s.length - 1)));

  @override
  Parser numberToken() =>
      super.numberToken().map((s) => Lambda.value(toNum(s)));

  @override
  Parser trueToken() => super.trueToken().map((_) => Lambda.value(true));

  @override
  Parser funcName() => super.funcName().map((value) => value.join());

  @override
  Parser falseToken() => super.falseToken().map((_) => Lambda.value(false));
}

dynamic toNum(String s) {
  final doubleValue = double.parse(s);
  final intValue = doubleValue.toInt();
  if (intValue - doubleValue == 0) {
    return intValue;
  } else {
    return doubleValue;
  }
}
