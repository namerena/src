part of md5;

class SklAccumulate extends ActionSkl implements UpdateStateProc, IMeta{

  UpdateStateImpl onUpdateState;
  SklAccumulate(){
    onUpdateState = new UpdateStateImpl(this);
  }

  bool prob(R r, bool smart) {
    if (onUpdateState.list != null) {
      return false;
    }
    if (smart) {
      if (owner.hp < 120) {
        return false;
      }
      if (owner.meta[Dt.accumulate] != null) {
        return false;
      }
    }
    return super.prob(r, smart);
  }

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    updates.add(new RunUpdate(l('[0]开始[聚气]', 'sklAccumulate'), owner, owner, null, null, 1));
    owner.updatestates.add(onUpdateState);
    owner.meta[Dt.accumulate] = this;
    if (owner.meta.containsKey(Dt.charge)) {
      acc += 1;
      owner.spsum += 500;
    }
    owner.updateStates();
    owner.spsum += 400;
    updates.add(new RunUpdate(l('[1]攻击力上升', 'sklAccumulated') + Dt.s_accumulate, owner, owner));
  }
  double acc = 1.7;
  void updateState(Plr p) {
    p.atboost *= acc;
  }

  // meta
  int get metaType => 1;
  void destroy(Plr caster, RunUpdates updates) {
    onUpdateState.unlink();
    owner.meta.remove(Dt.accumulate);
    owner.updateStates();
    if (caster != null) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(
                     l('[1]的[聚气]被打消了', 'sklAccumulateCancel'), caster, owner));
    }
    acc = 1.6;
  }
  Plr get target => owner;
}
