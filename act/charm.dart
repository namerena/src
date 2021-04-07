part of md5;

class CharmState extends UpdateStateEntry implements IMeta, PostActionProc {
  Grp grp;
  final Plr target;

  CharmState(this.grp, this.target) {
    onPostAction = new PostActionImpl(this);
  }

  // nagetive meta
  int get metaType => -1;

  PostActionImpl onPostAction;

  void updateState(Plr p) {
    target.allyGroup = grp;
  }

  int step = 1;

  void postAction(R r, RunUpdates updates) {
    step--;
    if (step == 0) {
      destroy(null, updates);
    }
  }

  void add() {
    target.meta[Dt.charm] = this;
    target.updatestates.add(this);
    target.postactions.add(onPostAction);
    target.updateStates();
  }

  void destroy(Plr caster, RunUpdates updates) {
    unlink();
    target.meta.remove(Dt.charm);
    onPostAction.unlink();
    target.updateStates();
    if (target.alive) {
      updates.add(RunUpdate.newline);
      updates.add(
          new RunUpdateCancel(l('[1]从[魅惑]中解除', 'sklCharmEnd'), caster, target));
    }
  }
}

class SklCharm extends ActionSkl {
  bool validTarget(Plr target, bool smart) {
    if (smart) {
      if (target.meta.containsKey(Dt.charm) &&
          (target.meta[Dt.charm] as CharmState).step > 1) {
        return false;
      }
    }
    return true;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    double rslt = super.scoreTargetImpl(target, smart, r, true);
    if (target.meta[Dt.charm] != null || target.meta[Dt.berserk] != null) {
      rslt /= 2;
    }
    return rslt;
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    updates.add(new RunUpdate(
        l('[0]使用[魅惑]', 'sklCharm'), owner, target, null, null, 1));

    if (target.immune(Dt.charm, r) ||
        (target.active && Alg.dodge(owner.mag, target.agl + target.mdf, r))) {
      updates.add(new RunUpdate(
          l('[0][回避]了攻击', 'dodge'), target, owner, null, null, 20));
      return;
    }

    CharmState charmState = target.meta[Dt.charm] as CharmState;
    if (charmState == null) {
      charmState = new CharmState(owner.allyGroup, target);
      charmState.add();
    } else if (owner.allyGroup != charmState.grp) {
      charmState.grp = owner.allyGroup;
    } else {
      charmState.step++;
    }
    if (owner.meta.containsKey(Dt.charge)) {
      charmState.step += 3;
    }
    updates.add(new RunUpdate(l('[1]被[魅惑]了', 'sklCharmHit') + Dt.s_charm, owner,
        target, null, null, 120));
  }
}
