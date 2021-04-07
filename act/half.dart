part of md5;

class SklHalf extends ActionSkl {
  SklHalf();

  bool validTarget(Plr target, bool smart) {
    if (smart) {
      return target.hp > 100;
    }
    return true;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    return scoreTargetImpl(target, smart, r, true) * target.hp;
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;
    updates.add(
        new RunUpdate(l('[0]使用[瘟疫]', 'sklHalf'), owner, target, null, null, 1));

    int chance = (400 - target.hp) ~/ 3;
    if (chance < 0) {
      chance = 0;
    }
    if (target.immune(Dt.half, r) ||
        (target.active &&
            !owner.meta.containsKey(Dt.charge) &&
            Alg.dodge(chance, target.mdf + target.agl, r))) {
      updates.add(new RunUpdate(
          l('[0][回避]了攻击', 'dodge'), target, owner, null, null, 20));
      return;
    }
    int oldhp = target.hp;

    int x = (owner.mag - target.mdf ~/ 2) ~/ 2 + 47;
    if (owner.meta.containsKey(Dt.charge)) {
      x = owner.mag + 50;
    }
    if (x > 99) {
      x = 99;
    }

    target.hp = (target.hp * (100 - x) / 100).ceil();
    int damaged = oldhp - target.hp;
    updates.add(new RunUpdate(l('[1]体力减少[2]%', 'sklHalfDamage'), owner,
        new HPlr(target, oldhp), new HDamage(x), null, damaged));

    if (damaged > 0) {
      target.onDamaged(damaged, oldhp, owner, r, updates);
    }
  }
}
