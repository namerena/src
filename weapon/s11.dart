part of md5;


class SklS11 extends ActionSkl {
  static List attrNames = l(' 攻 [] 防 [] 速 [] 敏 [] 魔 [] 抗 [] 智 []', 'detail')
      .split('[]').map((str) => str.trim())
      .toList();

  int chance = 3;

  SklS11() {
    boosted = true;
  }

  bool prob(R r, bool smart) {
    if (level == 0) {
      return false;
    }
    return r.r63 + level > owner.itl;
  }

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    updates.add(new RunUpdate(l('[0]在促销日[购买]了武器', 'weaponS11_0'), owner));
    if (r.c25) {
      updates.add(new RunUpdate(l('但是并没有什么用', 'weaponS11_1'), owner));
      chance --;
    } else {
      int attrIdx = r.nextInt(7);
      int attrVal = r.r31 + 6;
      owner.attr[attrIdx] += attrVal;
      owner.updateStates();
      updates.add(new RunUpdate(
          '[${attrNames[attrIdx]}]' + l('增加了[2]点', 'weaponS11_2'), owner, null,
          attrVal));
    }
    owner.spsum += 1024;
    chance -= r.r3;
    if (chance <= 0) {
      updates.add(new RunUpdate(l('[0]信用卡刷爆', 'weaponS11Done1'), owner));
      if (level < 20) {
        updates.add(new RunUpdate(l('[0]砍下了自己的左手', 'weaponS11Done3'), owner));
        level = 0;
      } else {
        updates.add(new RunUpdate(l('[0]砍下了自己的右手', 'weaponS11Done2'), owner));
        level = 1;
      }

      owner.damage(r.r31 + 16, owner, Skill.onDamage, r, updates);
    }
  }


}

class WeaponS11 extends Weapon {
  WeaponS11(String name, Plr p) :super._(name, p);

  void init(R r) {
    super.init(r);
    attrAdd = [11, 0, 11, 0, 0, 0, 0, 0];
  }

  void upgradeSkill() {
    p.sortedSkills.add((new SklS11())
      ..init(p, 31));
  }
}