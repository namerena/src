part of md5;

class SklCharge extends ActionSkl implements PostActionProc, UpdateStateProc, IMeta{

  UpdateStateImpl onUpdateState;
  PostActionImpl onPostAction;
  SklCharge(){
    onUpdateState = new UpdateStateImpl(this);
    onPostAction = new PostActionImpl(this);
  }

  bool prob(R r, bool smart) {
    if (owner.meta.containsKey(Dt.charge)) {
      return false;
    }
    if (smart) {
      if (owner.hp < 100) {
        return false;
      }
    }
    return super.prob(r, smart);
  }

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {

    updates.add(new RunUpdate(l('[0]开始[蓄力]', 'sklCharge'), owner, owner, null, null, 1));
    step += 2;
    owner.postactions.add(onPostAction);
    owner.updatestates.add(onUpdateState);
    owner.meta[Dt.charge] = this;
    owner.updateStates();
    owner.mp += 32;
  }

  int step = 0;
  void postAction(R r, RunUpdates updates) {
    step--;
    if (step <= 0) {
      destroy(null, updates);
    }
  }

  void updateState(Plr p) {
    p.atboost *= 3;
  }

  // meta
  int get metaType => 1;
  void destroy(Plr caster, RunUpdates updates) {
    onPostAction.unlink();
    onUpdateState.unlink();
    owner.meta.remove(Dt.charge);
    owner.updateStates();
    if (caster != null) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(
                     l('[1]的[蓄力]被中止了', 'sklChargeCancel'), caster, owner));
    }
  }
  Plr get target => owner;
}
