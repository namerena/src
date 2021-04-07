part of md5;

class IceState extends UpdateStateEntry implements IMeta, PreStepProc {
  final Plr target;

  IceState(this.target) {
    preStepImpl = new PreStepImpl(this);
  }

  // nagetive meta
  int get metaType => -1;

  PreStepImpl preStepImpl;

  void updateState(Plr p) {
    p.frozen = true;
  }

  /// fully frozen time
  int frozenStep = 1024;

  int preStep(int step, R r, RunUpdates updates) {
    if (step > 0) {
      if (frozenStep > 0) {
        frozenStep -= step;
        return 0;
      } else if (step + target.spsum >= 2048) {
        destroy(null, updates);
        return 0;
      }
    }
    return step;
  }

  void add() {
    target.meta[Dt.ice] = this;
    target.updatestates.add(this);
    target.presteps.add(preStepImpl);
    target.updateStates();
  }

  void destroy(Plr caster, RunUpdates updates) {
    unlink();
    target.meta.remove(Dt.ice);
    preStepImpl.unlink();
    target.updateStates();
    if (target.alive) {
      updates.add(RunUpdate.newline);
      updates.add(
          new RunUpdateCancel(l('[1]从[冰冻]中解除', 'sklIceEnd'), caster, target));
    }
  }
}

class SklIce extends ActionSkl {
  static void onDamage(
      Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    if (dmg > 0 && !target.dead) {
      if (target.immune(Dt.ice, r)) {
        return;
      }

      IceState iceState = target.meta[Dt.ice] as IceState;
      if (iceState == null) {
        iceState = new IceState(target);
        iceState.add();
      } else {
        iceState.frozenStep += 1024;
      }

      if (caster.meta.containsKey(Dt.charge)) {
        iceState.frozenStep += 2048;
      }
      updates.add(new RunUpdate(l('[1]被[冰冻]了', 'sklIceHit') + Dt.s_ice, caster,
          target, null, null, 40));
    }
  }

  double scoreTarget(Plr target, bool smart, R r) {
    double rslt = super.scoreTarget(target, smart, r);
    if (target.meta[Dt.ice] != null) {
      rslt /= 2;
    }
    return rslt;
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    double atp = Alg.getAt(owner, true, r) * 0.7;
    updates.add(
        new RunUpdate(l('[0]使用[冰冻术]', 'sklIce'), owner, target, null, null, 1));
    target.attacked(atp, true, owner, onDamage, r, updates);
  }
}
