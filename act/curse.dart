part of md5;

class CurseState extends PostDefendEntry implements IMeta, UpdateStateProc {

  final Plr owner;
  final Plr target;

  UpdateStateImpl onUpdateState;
  CurseState(this.owner, this.target) {
    onUpdateState = new UpdateStateImpl(this);
  }

  // nagetive meta
  int get metaType => -1;


  int prob = 42;
  int multiply = 2;

  int postDefend(int dmg, Plr caster, ondmg(Plr caster, Plr target, int dmg, R r, RunUpdates updates), R r, RunUpdates updates) {
    if (dmg > 0 && r.r63 < prob) {
      updates.add(new RunUpdate(l('[诅咒]使伤害加倍','sklCurseDamage'), owner, target));
      dmg *= multiply;
    }
    return dmg;
  }

  void updateState(Plr p) {
    p.atksum *= 4;
  }

  void add() {
    target.meta[Dt.curse] = this;
    target.postdefends.add(this);
    target.updatestates.add(onUpdateState);
    target.updateStates();
  }
  void destroy(Plr caster, RunUpdates updates) {
    unlink();
    target.meta.remove(Dt.curse);
    target.updatestates.remove(onUpdateState);
    target.updateStates();
    if (target.alive) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(l('[1]从[诅咒]中解除','sklCurseEnd'), caster, target));
    }
  }

}

class SklCurse extends ActionSkl {

  bool validTarget(Plr target, bool smart) {
    if (smart) {
      if (target.hp < 80 || (target.meta.containsKey(Dt.curse) && (target.meta[Dt.curse] as CurseState).prob > 32)) {
        return false;
      }
    }
    return true;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    double rslt = super.scoreTarget(target, smart, r);
    if (target.meta[Dt.curse] != null) {
      rslt /= 2;
    }
    return rslt;
  }


  static void onDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    if (dmg > 0 && !target.dead) {
      if (target.immune(Dt.curse, r)) {
        return;
      }

      CurseState curseState = target.meta[Dt.curse] as CurseState;
      if (curseState == null) {
        curseState = new CurseState(caster, target);
        curseState.add();
      } else {
        curseState.prob += 10;
        curseState.multiply ++;
      }
      if (target.meta[Dt.charge] != null ) {
        curseState.prob += 10;
        curseState.multiply ++;
      }
      updates.add(new RunUpdate(l('[1]被[诅咒]了', 'sklCurseHit') + Dt.s_curse, caster, target, null, null, 60));
    }
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    double atp = Alg.getAt(owner, true, r);
    updates.add(new RunUpdate(l('[0]使用[诅咒]', 'sklCurse'), owner, target, null, null, 1));
    target.attacked(atp, true, owner, onDamage, r, updates);
  }
}
