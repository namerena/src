part of md5;


class HasteState extends UpdateStateEntry implements IMeta, PostActionProc {
  final Plr owner;
  final Plr target;
  HasteState(this.owner, this.target) {
    onPostAction = new PostActionImpl(this);
  }
  // positive meta
  int get metaType => 1;

  PostActionImpl onPostAction;

  int faster = 2;
  void updateState(Plr p) {
    target.spd *= faster;
  }

  int step = 3;

  void postAction(R r, RunUpdates updates) {
    step--;
    if (step == 0) {
      destroy(null, updates);
    }
  }

  void add() {
    target.meta[Dt.haste] = this;
    target.updatestates.add(this);
    target.postactions.add(onPostAction);
    target.updateStates();
  }
  void destroy(Plr caster, RunUpdates updates) {
    unlink();
    target.meta.remove(Dt.haste);
    onPostAction.unlink();
    target.updateStates();
    if (target.alive) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(l('[1]从[疾走]中解除','sklHasteEnd'), caster, target));
    }
  }
}

class SklHaste extends ActionSkl {

  Plr selectOneTarget(R r) {
    return r.pick(owner.allyGroup.alives);
  }

  bool validTarget(Plr target, bool smart) {
    if (smart) {
      if (target.hp < 60) {
        return false;
      }
      if (target.meta[Dt.haste] != null && ((target.meta[Dt.haste] as HasteState).step + 1) * 60 > target.hp) {
        return false;
      }
      return target is! Minion;
    }
    return true;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    if (smart) {
      double rslt = Alg.rateHiHp(target) * target.attrsum;
      if (target.meta[Dt.haste] != null) {
        rslt /= 2;
      }
      return rslt;
    }
    return r.rFFFF.toDouble();
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    updates.add(new RunUpdate(l('[0]使用[加速术]', 'sklHaste'), owner, target, null, null, 60));
    owner.spsum += owner.spd ;

    HasteState hasteState = target.meta[Dt.haste] as HasteState;
     if (hasteState == null) {
       hasteState = new HasteState(this.owner, target);
       hasteState.add();
     } else {
       hasteState.step += 4;
     }
     if (owner.meta.containsKey(Dt.charge)) {
       hasteState.faster += 2;
       hasteState.step += 2;
     }
     updates.add(new RunUpdate(l('[1]进入[疾走]状态', 'sklHasteHit') + Dt.s_haste, owner, target));
  }
}
