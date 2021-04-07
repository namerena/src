library md5.tunnel;
import 'dart:html';
import 'lan.dart';
import 'dart:async';

StreamController<String> sc = new StreamController();
void tunnelWrite(String str){
  if (_tunnelCallback != null) {
    _tunnelCallback(str);
  }
  sc.add(str);
}

typedef _TunnelCallback = void Function(String s);
_TunnelCallback _tunnelCallback;
void tunnelReadAsync(callback(String str)) {
  _tunnelCallback = callback;
}
String tunnelReadSync() {
  return null;
}

