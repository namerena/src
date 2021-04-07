library md5.runner;

import 'dart:html';
import 'dart:math';
import 'dart:js' as Js;
import 'dart:convert';




import '../md5.dart';
import '../html/html.dart';


import 'dart:async';
import 'package:hashdown/rc4.dart';

md5run() async{
  await HtmlRenderer.init();
  try {
    String t = window.sessionStorage[h_('k')];
    var decoded = Base2e15.decode(t);
    String names = utf8.decode(decoded);
    List<List<List<String>>> parsed = Fgt.parseString(names);


    Fgt f = await Fgt.make(parsed);
    HtmlRenderer renderer = new HtmlRenderer(f);

  } catch (err, stack) {
    debug(err);
  }
}
