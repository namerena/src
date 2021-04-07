part of md5;


class PlrBoost extends Plr {
  int boost;
  PlrBoost(String baseName, String clanName, this.boost, String weaponName) : super(baseName, clanName, baseName, weaponName){
    for (int i = 6; i < 50; ++i) {
      ss[i] |= 32;
      ss[i] += boost;
    }
    for (int i = 13; i < 16; ++i) {
      ss[i] += boost;//def
    }
    for (int i = 25; i < 28; ++i) {
      ss[i] += boost;//mdf
    }
    for (int i = 64; i < 128; ++i) {
      ss[i] |= 16;
      ss[i] += boost;
    }
  }
  bool immune(String key, R r) {
    return r.r127 < boost;
  }
}

/// test account
class PlrTest extends Plr {
  PlrTest(String baseName, String clanName, Fgt fgt) : super(baseName, clanName, baseName) {
    for (int i = 0; i < 50; ++i) {
       if (ss[i] < 12) {
         ss[i] = 63 -  ss[i];
       }
     }
  }
}
class PlrTest2 extends Plr {
  PlrTest2(String baseName, String clanName) : super(baseName, clanName, baseName) {
    for (int i = 0; i < 50; ++i) {
       if (ss[i] < 32) {
         ss[i] = 63 -  ss[i];
       }
     }
  }
}

class PlrEx extends Plr {
  PlrEx(String baseName, [String clanName, String sglName, String weaponName]) : super(baseName, clanName, sglName, weaponName) {
    for (int i = 6; i < 50; ++i) {
      if (ss[i] < 41) {
        ss[i] = (ss[i] & 15) + 41;
      }
    }
    for (int i = 50; i < 128; ++i) {
      if (ss[i] < 16) {
        ss[i] += 32;
      }
    }
    ss0 = []..addAll(ss);
  }
  void upgrade(List<int> ssx) {
    // not allowed
  }
}
