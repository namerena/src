library md5.lan;
import 'dart:math';
import 'dart:convert';
import 'package:base2e15/base2e15.dart';
part 'lan_data.dart';


String h_(String str) {
  int a = 1;
  int b = 3;
  int c = 5;
  int d = 7;
  for (int n in str.codeUnits) {
    a = (a + n + d) * 17 % 52;
    b = (b + n * a) * 23 % 52;
    c = (c + n + b) * 47 % 52;
    d = (d + n * c) * 41 % 52;
  }
  if (a < 26) a += 65;
    else a += 71;
  if (b < 26) b += 65;
    else b += 71;
  if (c < 26) c += 65;
    else c += 71;
  if (d < 26) d += 65;
      else d += 71;
  return new String.fromCharCodes([a, b, c, d]);
}

Random rng = new Random();
