
abstract class BaseFlow with FlowListener {
  dynamic _last;

  bool get isListening => _onListen != null;

  @override
  dynamic get last => _last ?? super.last;

  void add(dynamic data) {
    _last = data;
    if (_onListen != null) {
      _onListen(data);
    } else {
      _remains.add(data);
    }
  }
}

class Flow extends BaseFlow {
  Flow();

  factory Flow.combine(List<FlowListener> flows,
          {FlowCombiner combiner, List initialValues}) =>
      CombinerFlow(flows, combiner: combiner, initialValues: initialValues);

  factory Flow.withValues(List values) => Flow().._remains = values;
}

typedef FlowCombiner = dynamic Function(List);

class CombinerFlow extends Flow {
  final List<FlowListener> flows;

  CombinerFlow(this.flows, {FlowCombiner combiner, List initialValues}) {
    final converter = combiner ?? (values) => values;
    final length = flows.length;
    final list = initialValues ?? List(length);
    // ignore: omit_local_variable_types
    int index = 0;
    final onUpdate = (int index) => (value) => list[index] = value;
    // ignore: omit_local_variable_types
    int target = initialValues?.length ?? 0;
    flows.forEach((f) {
      final onUpdateForStream = onUpdate(index++);
      // ignore: omit_local_variable_types
      bool isFirstElement = initialValues == null;
      f.listen((value) {
        onUpdateForStream(value);
        if (isFirstElement) {
          target++;
          isFirstElement = false;
        }
        if (target == length) add(converter(List.unmodifiable(list)));
      });
    });
  }

  @override
  void cancel() {
    super.cancel();
    flows.forEach((element) {
      element.cancel();
    });
  }
}

mixin FlowListener {
  Function(dynamic) _onListen;
  List _remains = [];
  dynamic get last => _remains.last;

  void listen(Function(dynamic) onListen) {
    _onListen = onListen;
    while (_remains.isNotEmpty) {
      _onListen(_remains.first);
      _remains.removeAt(0);
    }
  }

  void cancel() {
    _onListen = null;
  }
}

/*typedef FlowBuilderFunc = Widget Function(BuildContext context, dynamic data);

class FlowBuilder extends StatefulWidget {
  final FlowBuilderFunc builder;
  final FlowListener flow;
  final dynamic initialData;

  const FlowBuilder({this.initialData, this.builder, this.flow});

  @override
  _FlowBuilderState createState() => _FlowBuilderState();
}

class _FlowBuilderState extends State<FlowBuilder> {
  dynamic data;

  @override
  void initState() {
    super.initState();
    data = widget.initialData;
    widget.flow?.listen((value) {
      setState(() {
        data = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.flow?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, data);
  }
}

mixin FlowMixin<T extends StatefulWidget> on State<T>{
  Flow flow;
  @override
  void initState() {
    super.initState();
    flow = Flow();
  }

  @override
  void dispose() {
    super.dispose();
    flow.cancel();
    flow = null;
  }
}*/
