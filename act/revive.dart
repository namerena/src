part of md5;

class SklRevive extends ActionSkl {
  bool get allowSneak => false;
  Plr selectOneTarget(R r) {
    return r.pick(owner.allyGroup.players);
  }

  bool validTarget(Plr target, bool smart) {
    return target.dead && (target is! Minion) && !target.meta.containsKey(Dt.corpose);
  }

  double scoreTarget(Plr target, bool smart, R r) {
    if (smart) {
      return target.attrsum.toDouble();
    }
    return r.rFFFF.toDouble();
  }
  
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    level = (level+1) ~/ 2;
    
    Plr target = targets[0].p;

    double atp = Alg.getAt(owner, true, r);
    int healedhp = (atp/75.0).ceil();
    if (healedhp > target.maxhp ) {
      healedhp = target.maxhp;
    }
    updates.add(new RunUpdate(l('[0]使用[苏生术]', 'sklRevive'), owner, target, null, null, 1));
    updates.add(new RunUpdate(l('[1][复活]了', 'sklRevived') + Dt.s_revive, owner, target, null, null, healedhp + 60));
    target.hp = healedhp;
    target.revive(r, updates);
    updates.add(
        new RunUpdate(l('[1]回复体力[2]点','recover'), owner, new HPlr(target, 0), new HRecover(healedhp)));
  }
}
