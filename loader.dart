library md5.loader;
import 'dart:js' as Js;
import 'dart:html';
import 'lan.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:hashdown/rc4.dart';
import 'package:base2e15/base2e15.dart';
import 'package:hashdown/hashdown.dart';
import 'helper.dart';
import 'connect/connector.dart';
import 'html/image.dart';

part 'loaderui.dart';
part 'loaderui_boss.dart';

RC4 rc;

class JsLoader{
  String name;
  Js.JsObject loader;
  Function callback;
  JsLoader(this.name, this.callback){
    loader = Js.context[name] as Js.JsObject;
    var response = loader['responseText'];
    if (loader['readyState'] == 4 && response is String && response != '') {
      Timer(Duration(seconds: 0), ()=>loaded(response));
    } else {
      loader.callMethod('addEventListener', ['load', onLoad]);
    }
    Js.context[name] = null;
  }
  void onLoad(Event e){
    var response = loader['responseText'];
    if (response is String && response != '') {
      loaded(response);
    }
  }

  String result;
  loaded(String txt) {
    result = txt;
    callback();
  }
}

List rngx;
Map lanmap;
LoaderUi _ui;
Js.JsObject win = Js.context.callMethod('cw',[]) as Js.JsObject;
IFrameElement iframe = querySelector('.mdframe') as IFrameElement;

JsLoader lanLoader;
JsLoader jsLoader;
JsLoader cssLoader;
JsLoader htmlLoader;
load() async{


  rngx = [];
  for (int i = 0; i < 8; ++i) {
    rngx.add(rng.nextInt(256));
  }
  lanLoader = new JsLoader('req0', lanLoaded);
  jsLoader = new JsLoader('req1', jsLoaded);
  cssLoader = new JsLoader('req2', jsLoaded);
  htmlLoader = new JsLoader('req3', jsLoaded);

  iframe.onLoad.listen(onIframeLoad);
}
void lanLoaded() {
  // load language
  lanmap = json.decode(lanLoader.result) as Map;
  window.sessionStorage['HHbf'] =lanLoader.result;
  loadLan(lanmap);
  _ui = new LoaderUi();
  Element loader = querySelector('.loaderbg');
  if (loader.style.opacity != '0') {
    loader.style.opacity = '0.2';
  }
  loader.style.pointerEvents = 'none';
}
String lastjs;
void jsLoaded() {
  if (htmlLoader !=null && jsLoader.result != null && cssLoader.result != null && htmlLoader.result != null) {
    lastjs = jsLoader.result.replaceFirst('[1,3,0,9]', rngx.toString());
    Blob blob = new Blob([cssLoader.result], "text/css");
    String cssUrl = Url.createObjectUrlFromBlob(blob);
    String htmlData = htmlLoader.result.replaceFirst('md5.css', cssUrl);
    blob = new Blob([htmlData], "text/html");
    String htmlUrl = Url.createObjectUrlFromBlob(blob);
    iframe.src = htmlUrl;
    if (lastNames != null) {
      new Timer(new Duration(seconds:1), wechatCheck);
    }
    querySelector('.loaderbg').style.opacity = '0';
  }
}

String lastNames;
void run(String names){
  lastNames = names;
  if (lastjs != null) {
    Js.context.callMethod('rld',[win['location']]);
  }
}

void onIframeLoad(Event e){
  if (lastNames == null || lastjs == null) {
    return;
  }
  jsLoadedOnce = true;

//  rc = new RC4([], 0);
//  rc.S = hostList.toList();
//  rc.encryptBytes(rngx.toList());
  List<int> nameBytes = utf8.encode(lastNames);
//  rc.encryptBytes(nameBytes);
  String out = Base2e15.encode(nameBytes);
  window.sessionStorage['fYwD'] = out;

  win.callMethod('eval',[lastjs]);
}
bool jsLoadedOnce = false;
void wechatCheck() {
  if (!jsLoadedOnce) {
    Js.context.callMethod('rld',[win['location']]);
  }
}
