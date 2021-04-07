part of md5;

class FireState extends IMeta {
  final Plr target;
  FireState(this.target);
  // nagetive meta
  int get metaType => -1;

  double fireMag = 0.0;

}

class SklFire extends ActionSkl {
  static void onFire(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    if (dmg > 0 && !target.dead) {
      if (target.immune(Dt.fire, r)) {
        return;
      }
      FireState fireState = target.meta[Dt.fire] as FireState;
      if (fireState == null) {
        fireState = new FireState(target);
        target.meta[Dt.fire] = fireState;
      }
      fireState.fireMag = fireState.fireMag + 0.5;
    }
  }
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    FireState fireState = target.meta[Dt.fire] as FireState;
    if (fireState == null) {
      fireState = new FireState(target);
    }
    double atp = Alg.getAt(owner, true, r) * (1.5  + fireState.fireMag); // 1.4
    updates.add(new RunUpdate(l('[0]使用[火球术]','sklFire'), owner, target, null, null, 1));
    target.attacked(atp, true, owner, onFire, r, updates);

  }
}
