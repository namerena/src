part of md5;

class SklHeal extends ActionSkl {
  bool get allowSneak => false;
  Plr selectOneTarget(R r) {
    return r.pick(owner.allyGroup.alives);
  }

  bool validTarget(Plr target, bool smart) {
    if (smart) {
      return target.hp + 80 < target.maxhp;
    }
    return target.hp < target.maxhp;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    if (smart) {
      int damaged = target.maxhp - target.hp;
      target.meta.forEach((key, val){
        if (val.metaType < 0) {
          damaged += 64;
        }
      });
      damaged *= target.attrsum;
      return damaged.toDouble();
    }
    return r.rFFFF.toDouble();
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    if (level > 8) level--;

    Plr target = targets[0].p;

    double atp = Alg.getAt(owner, true, r);
    int healedhp = (atp/60.0).ceil();
    if (healedhp > target.maxhp - target.hp) {
      healedhp = target.maxhp - target.hp;
    }
    updates.add(new RunUpdate(l('[0]使用[治愈魔法]', 'sklHeal'), owner, target, null, null, healedhp));
    int oldhp = target.hp;
    target.hp += healedhp;
    updates.add(
        new RunUpdate(l('[1]回复体力[2]点','recover'), owner, new HPlr(target, oldhp), new HRecover(healedhp)));
    target.clearStates(owner, updates);

  }
}
