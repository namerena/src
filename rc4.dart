library md5.rc4;

import 'package:hashdown/rc4.dart';
import 'dart:convert';

class R extends RC4 {
  static List<int> utf(String str) {
    return [0]..addAll(utf8.encode(str));
  }

  R(List<int> key, [int round = 1]) : super(key, round);

  void round(List<int> key, [int round = 1]) {
    int keylen = key.length;
    for (int r = 0; r < round; ++r) {
      int j = 0;
      for (int i = 0; i < 256; ++i) {
        int keyv = key[i % keylen];
        j = (j + S[i] + keyv) & 0xFF;
        int t = S[i];
        S[i] = S[j];
        S[j] = t;
      }
    }
    i = j = 0;
  }

  List<T> sortList<T>(List<T> list) {
    if (list.length <= 1) {
      return list;
    }
    int n = list.length;
    List<int> X = [];
    X.length = n;
    for (int i = 0; i < n; ++i) {
      X[i] = i;
    }
    int b = 0;
    for (int i = 0; i < 2; ++i) for (int a = 0; a < n; ++a) {
      int keyv = nextInt(n);
      b = (b + X[a] + keyv) % n;
      int t = X[a];
      X[a] = X[b];
      X[b] = t;
    }
    return X.map((e) => list[e]).toList();
  }

  T pick<T>(List<T> list) {
    if (list != null) {
      if (list.length == 1) {
        return list[0];
      } else if (list.length > 1) {
        return list[nextInt(list.length)];
      }
    }
    return null;
  }

  T pickSkip<T>(List<T> list, T obj) {
    if (list != null) {
      if (list.length == 1) {
        if (list[0] != obj) {
          return list[0];
        }
      } else if (list.length > 1) {
        int pos = list.indexOf(obj);
        if (pos < 0) {
          return list[nextInt(list.length)];
        }
        int n = nextInt(list.length - 1);
        if (n >= pos) {
          ++n;
        }
        return list[n];
      }
    }
    return null;
  }

  T pickSkipRange<T>(List<T> list, List<T> skips) {
    if (skips == null || skips.isEmpty) {
      return pick(list);
    }
    T first = skips.first;
    int skiplen = skips.length;
    if (list != null) {
      if (list.length > skiplen) {
        int pos = list.indexOf(first);
        int n = nextInt(list.length - skiplen);
        if (n >= pos) {
          n += skiplen;
        }
        return list[n];
      }
    }
    return null;
  }

  bool get c94 {
    return nextByte() < 240;
  }

  bool get c75 {
    return nextByte() < 192;
  }

  bool get c50 {
    return nextByte() < 128;
  }

  bool get c25 {
    return nextByte() < 64;
  }
  bool get c12 {
    return nextByte() < 32;
  }

  bool get c33 {
    return nextByte() < 84;
  }
  bool get c66 {
    return nextByte() < 171;
  }

  int get rFFFFFF {
    return nextByte() << 16 | nextByte() << 8 | nextByte();
  }

  int get rFFFF {
    return nextByte() << 8 | nextByte();
  }

  int get r256 {
    return nextByte() + 1;
  }

  int get r255 {
    return nextByte();
  }

  int get r127 {
    return nextByte() & 127;
  }

  int get r64 {
    return (nextByte() & 63) + 1;
  }

  int get r63 {
    return nextByte() & 63;
  }

  /// used by req mp
  int get r3x3 {
    int b = nextByte();
    int b1 = (b & 15) + 1;
    int b2 = ((b >> 4) & 15) + 1;

    return ((b1 * b2) >> 5) + 1;
  }

  int get r31 {
    return nextByte() & 31;
  }

  int get r16 {
    return (nextByte() & 15) + 1;
  }

  int get r15 {
    return nextByte() & 15;
  }

  int get r7 {
    return nextByte() & 7;
  }

  int get r3 {
    return nextByte() & 3;
  }

  @override
  int nextInt(int max) {
    if (max == 0) {
      return 0;
    }
    int round = max;
    int v = nextByte();
    do {
      v = v << 8 | nextByte();
      if (v >= max) {
        v %= max;
      }
      round >>= 8;
    } while (round != 0);
    return v;
  }

  ShadowR _s0;

  /// algorithm patch
  R get s0 {
    if (_s0 == null) {
      _s0 = new ShadowR(this);
    }
    return _s0;
  }

  ShadowR _s1;

  /// unimportant PRNG
  R get s1 {
    if (_s1 == null) {
      _s1 = new ShadowR(this);
    }
    return _s1;
  }
}

class ShadowR extends R {
  R rc4;
  ShadowR(this.rc4) : super([], 0) {
    S = rc4.S;
  }
  int ii = 0;
  int jj = 0;
  int nextByte() {
    ii = (ii + 1) & 0xFF;
    jj = (jj + S[ii] + S[rc4.j]) & 0xFF;
    return S[(S[rc4.i] + S[jj]) & 0xFF];
  }
}
