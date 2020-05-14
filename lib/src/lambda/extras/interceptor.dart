

//import 'package:flurine/lab/canvas/scene.dart';

mixin Interceptor{
  Future<dynamic> intercept(dynamic value);
}

class SceneInterceptor with Interceptor{
  @override
  Future intercept(value) async{
    /*if(value is Scene){
      await value.start();
    }*/
    return value;
  }
}