
mixin MiddleWare<T> {
  void preProcess(T value){
    if(value!=null) onPreProcess(value);
  }
  void postProcess(T value){
    if(value!=null) onPostProcess(value);
  }
  void onPreProcess(T value);
  void onPostProcess(T value);
}

/*
class SceneMiddleWare with MiddleWare<Scene>{
  List<Lambda> _lambdas;
  @override
  void onPreProcess(Scene value) {
    _lambdas = value.lambdas;
  }

  @override
  void onPostProcess(Scene value) {
    value.lambdas= _lambdas;
  }

}*/
