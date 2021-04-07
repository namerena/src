part of md5;


class SlowState extends UpdateStateEntry implements IMeta, PostActionProc {
  final Plr owner;
  final Plr target;
  SlowState(this.owner, this.target) {
    onPostAction = new PostActionImpl(this);
  }
  // nagetive meta
  int get metaType => -1;

  PostActionImpl onPostAction;

  void updateState(Plr p) {
    target.spd ~/= 2;
  }

  int step = 2;

  void postAction(R r, RunUpdates updates) {
    step--;
    if (step == 0) {
      destroy(null, updates);
    }
  }

  void add() {
    target.meta[Dt.slow] = this;
    target.updatestates.add(this);
    target.postactions.add(onPostAction);
    target.updateStates();
  }
  void destroy(Plr caster, RunUpdates updates) {
    unlink();
    target.meta.remove(Dt.slow);
    onPostAction.unlink();
    target.updateStates();
    if (target.alive) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(l('[1]从[迟缓]中解除','sklSlowEnd'), caster, target));
    }
  }
}

class SklSlow extends ActionSkl {
  bool validTarget(Plr target, bool smart) {
    if (smart) {
      if (target.hp < 80 || (target.meta.containsKey(Dt.slow) && (target.meta[Dt.slow] as SlowState).step > 1)) {
        return false;
      }
    }
     return true;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    double rslt = super.scoreTargetImpl(target, smart, r, true);
    if (target.meta[Dt.slow] != null) {
      rslt /= 2;
    }
    return rslt;
  }


  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    updates.add(new RunUpdate(l('[0]使用[减速术]', 'sklSlow'), owner, target, null, null, 1));

    if (target.immune(Dt.slow, r) || (target.active && Alg.dodge(owner.mag, target.mdf, r))) {
       updates.add(new RunUpdate(l('[0][回避]了攻击','dodge'), target, owner, null, null, 20));
       return;
    }
    target.spsum -= target.spd + 64;
    SlowState slowState = target.meta[Dt.slow] as SlowState;
     if (slowState == null) {
       slowState = new SlowState(this.owner, target);
       slowState.add();
     } else {
       slowState.step += 2;
     }
     if (owner.meta.containsKey(Dt.charge)) {
       slowState.step += 4;
     }
     updates.add(new RunUpdate(l('[1]进入[迟缓]状态', 'sklSlowHit') + Dt.s_slow, owner, target, null, null, 60));
  }
}
