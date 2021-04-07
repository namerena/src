part of md5;

class Alg {

  static double getAt(Plr p, bool isMag, R r) {
    int atk;
    if (isMag) {
      atk = p.mag;
    } else {
      atk = p.atk;
    }
    int a = ([r.r127, r.r127, r.r127, atk + 64, atk]..sort())[2];
    int b = ([r.r63 + 64, r.r63 + 64, atk + 64]..sort())[1];
    return a * b * p.atboost;
  }

  static int getDf(Plr p, bool isMag, R r) {
    if (isMag) {
      return p.mdf + 64;
    }
    return p.def + 64;//([r.r63 + 64, r.r63 + def, def + 64]..sort())[1];
  }

  static bool dodge(int alA, int alD, R r) {
    int ch = 24 + alD - alA;
    if (ch < 7) ch = 7;
    if (ch > 64) ch = ch ~/ 4 + 48;
    return r.nextByte() <= ch;
  }

  static bool dodgeHpBase(int alA, int alD, int hp, R r) {
    int ch = 50 + alA - alD;
    if (ch < 7) ch = 7;
    return r.nextInt(hp) >= (ch * 4);
  }

  static double rateLowHp(Plr p) {
    return 1/rateHiHp(p);
  }

  static double rateHiHp(Plr p) {
    if (p.hp < 20) {
      return 30.0;
    }
    if (p.hp > 300) {
      return 300.0;
    }
    return p.hp.toDouble();
  }
}
