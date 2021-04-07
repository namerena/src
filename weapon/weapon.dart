part of md5;

class Weapon {

  static final specialList = {
    b('剁手刀'): (String name, Plr p) => new WeaponS11(name, p),
    b('死亡笔记'): (String name, Plr p) => new WeaponDeathNote(name, p),
    b('属性修改器'): (String name, Plr p) {
      if (p.clanName == Dt.rinick) {
        return new RinickModifier(name, p);
      } else {
        return new NoWeapon(name, p);
      }
    },
    b('桂月奖杯'): (String name, Plr p) {
      if (GuiYue.members.contains(p.clanName)) {
        return new GuiYue(name, p);
      } else {
        return new NoWeapon(name, p);
      }
    }
  };


  String baseName;
  String name;
  Plr p;
  List<int> ss;

  int sklId;

  int sklLevel;

  List<int> attrAdd = new List.filled(8, 0);

  factory Weapon(String name, Plr p){
    Weapon result;
    if (specialList.containsKey(name)) {
      result = specialList[name](name, p);
    } else if (name.endsWith(Dt.ex)) {
      result = new BossWeapon(name, p);
    } else {
      result = new Weapon._(name, p);
    }
    R r = new R(R.utf(result.baseName), 2);
    result.init(r);
    return result;
  }

  Weapon._(this.name, this.p) {
    baseName = name;
  }

  void init(R rc4) {
    ss = rc4.S.map((int n) => n & 63).toList();
    sklId = rc4.nextInt(40);

    int attrId = rc4.nextInt(8);

    List<int> sort;
    if (attrId == 6) {
      sort = ss.sublist(40, 48);
    } else {
      sort = ss.sublist(40, 48).map((int n) {
        if (n > 53) return n - 50;
        return 0;
      }).toList();
      sort[attrId] = 18;
    }

    int sum = 0;
    int count = 0;
    for (int i in sort) {
      if (i > 0) {
        count ++;
        sum += i;
      }
    }
    sum *= 3;

    List<int> attrLevels = (ss.sublist(0, 8)
      ..sort());
    int attrLevel = attrLevels[1] + attrLevels[4] + count;
    int attrHp = attrLevel;
    for (int i = 0; i < 7; ++i) {
      int t = attrLevel * sort[i] ~/ sum;
      attrHp -= t * 3;
      attrAdd[i] = t;
    }
    if (sort[7] > 0) {
      attrAdd[7] = attrHp;
    }
  }

  int upgrade3Number(List<int> base, List<int> current, List<int> up, int from) {
    int d0 = (up[from] - base[from]);
    int d1 = (up[from + 1] - base[from + 1]);
    int d2 = (up[from + 2] - base[from + 2]);
    if (d0 > 0 && d1 > 0 && d2 > 0) {
      int pos = (d0 + d1 + d2 + 999) % 3;
      int dd = (up[from + pos] - current[from + pos]) ~/ 2 + 1;
      if (dd > 0) {
        current[from + pos] += dd;
      }
    }
    return d0.abs() + d1.abs() + d2.abs();
  }

  void preUpgrade() {
    int attDiff = 0;
    for (int i = 10; i < 31; i += 3) {
      attDiff += upgrade3Number(p.ss0, p.ss, ss, i);
    }
    sklLevel = (480 - attDiff) ~/ 6;
    if (sklLevel < 0) {
      sklLevel = 0;
    }
  }

  void postUpgrade() {
    for (int i = 0; i < 8; ++i) {
      p.attr[i] += attrAdd[i];
    }
    upgradeSkill();
  }

  void upgradeSkill() {
    Skill skl = p.skills[sklId];
    if (skl.level == 0) {
      skl.boosted = true;
    }
    skl.level += sklLevel;
  }
}
