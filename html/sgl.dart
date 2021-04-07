library md5.sig;

import 'dart:html';
import 'dart:js' as Js;
import 'dart:async';
import 'dart:math' as Math;
import 'dart:convert';
import '../rc4.dart';
import 'image.dart';

part 'sgl_gen.dart';

class Sgls {
  static Map <String, String> dataUrls = {};
  static Map <String, String> sgls = {};
  static int iconidx = 0;
  static String getSglCss(String sglName){
    if (sgls.containsKey(sglName)) {
      return sgls[sglName];
    }
    String cssClass = 'icon_${iconidx++}';
    sgls[sglName] = cssClass;
    CanvasElement canvas = Sgl.createFromName(sglName) as CanvasElement;
    String dataurl = canvas.toDataUrl();
    dataUrls[sglName] = dataurl;
    CssStyleSheet style = document.styleSheets.last as CssStyleSheet;
    style.insertRule('div.$cssClass { background-image:url("$dataurl"); }', iconidx-1);
    return cssClass;
  }

  static void loadBossSgls() {
    Images.bosses.forEach((key, val) {
      String dataurl = 'data:image/gif;base64,$val';
      String cssClass = 'icon_${iconidx++}';
      String sglName = '$key@!';
      sgls[sglName] = cssClass;
      dataUrls[sglName] = dataurl;
      CssStyleSheet style = document.styleSheets.last as CssStyleSheet;
      style.insertRule('div.$cssClass { background-image:url("$dataurl"); }', iconidx-1);
    });
  }
}

