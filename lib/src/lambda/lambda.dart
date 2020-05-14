import 'handlers/handlers.dart';
import 'parser/lambda_parser.dart';
import '../vein/vein.dart';
import '../vein/flow.dart';
import 'parser/keywords.dart';

class Lambda {
  String type;
  List params;
  String key;
  LambdaExecutor executor = LambdaExecutor();

  SubVein get vein => executor.vein;

  Lambda(this.type, this.params);

  factory Lambda.parse(String text) => LambdaParser().parse(text).value;

  factory Lambda.value(dynamic value) => Lambda(CONST, [value]);

  factory Lambda.fromParsedString(String type, List<Lambda> params) {
    return Lambda(type, params);
  }

  factory Lambda.fromJson(dynamic data) {
    if (data is Map) {
      final type = data['t'];
      final params = data['p'];
      return Lambda.fromParsedString(type, params);
    }
    return Lambda.value(data);
  }

  dynamic toJson() {
    if (type == CONST) return params[0];
    return {
      'k': key,
      't': type.toString(),
      'p': params.map((p) => p.toJson()).toList()
    };
  }

  Future execute() async {
    await executor.init();
    await executor.execute(this);
  }

  Future update(dynamic value) async{
    // ignore: omit_local_variable_types
    Lambda lambda = value is Lambda ? value : Lambda.value(value);
    params = lambda.params;
    type = lambda.type;
    await executor.execute(this);
  }
}

class LambdaExecutor {
  SubVein vein;
  Flow paramsFlow = Flow();

  Future init() async {
    vein = await Vein.instance.createSubVein();
  }

  Future execute(Lambda lambda) async {
    if (lambda.type == CONST) {
      vein.run(ConstHandler()..params = lambda.params);
    } else {
      paramsFlow?.cancel();
      paramsFlow = await lambda.params.toFlow();
      paramsFlow.listen((parameters) {
        vein.run(Handler.builder(lambda.type)..params = parameters);
      });
    }
  }
}

extension on List<dynamic> {
  Future<CombinerFlow> toFlow() async {
    for (Lambda lambda in this) {
      await lambda.execute();
    }
    return Flow.combine(cast<Lambda>().map((e) => e.vein).toList());
  }
}
