part of md5;

class SklExchange extends ActionSkl {
  SklExchange();

  bool validTarget(Plr target, bool smart) {
    if (smart) {
      return target.hp - owner.hp > 32;
    }
    return target.hp > owner.hp;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    double rslt = super.scoreTargetImpl(target, smart, r, true);
    if (smart) {
      rslt *= target.hp;
    }
    return rslt;
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    level = (level + 1) ~/ 2;

    Plr target = targets[0].p;
    updates.add(new RunUpdate(
        l('[0]使用[生命之轮]', 'sklExchange'), owner, target, null, null, 1));

    if (target.immune(Dt.exchange, r) ||
        (target.active &&
            !owner.meta.containsKey(Dt.charge) &&
            Alg.dodge(owner.mag, target.mdf + target.def + target.agl, r))) {
      updates.add(new RunUpdate(
          l('[0][回避]了攻击', 'dodge'), target, owner, null, null, 20));
      return;
    }
    if (owner.meta.containsKey(Dt.charge)) {
      owner.spsum += target.spsum;
      target.spsum = 0;
    }

    int oldhp1 = owner.hp;
    int oldhp2 = target.hp;
    int delhp = oldhp2 - oldhp1;

    owner.hp = oldhp2;
    target.hp = oldhp1;
    if (owner.hp > owner.maxhp) {
      owner.hp = owner.maxhp;
    }

    updates.add(new RunUpdate(
        l('[1]的体力值与[0]互换', 'sklExchanged') + Dt.s_exchange,
        new HPlr(owner, oldhp1),
        new HPlr(target, oldhp2),
        null,
        null,
        delhp * 2));
    target.onDamaged(oldhp2 - target.hp, oldhp2, owner, r, updates);
  }
}
