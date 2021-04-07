part of md5;

class SklIron extends ActionSkl implements PostDefendProc, PostActionProc, IMeta, UpdateStateProc{
  double get sortId => 4000.0;
  PostDefendImpl onPostDefend;
  PostActionImpl onPostAction;
  UpdateStateImpl onUpdateState;
  SklIron(){
    onPostDefend = new PostDefendImpl(this);
    onPostAction = new PostActionImpl(this);
    onUpdateState = new UpdateStateImpl(this);
    onPostDefend.sortId = 10.0;
  }

  bool prob(R r, bool smart) {
    if (onPostDefend.list != null) {
      return false;
    }
    return super.prob(r, smart);
  }

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    updates.add(new RunUpdate(l('[0]发动[铁壁]', 'sklIron'), owner, owner, null, null, 60));
    owner.postdefends.add(onPostDefend);
    owner.postactions.add(onPostAction);
    owner.updatestates.add(onUpdateState);
    owner.meta[Dt.iron] = this;
    owner.updateStates();
    step = 3;
    protect = 110 + owner.mag ;
    if (owner.meta.containsKey(Dt.charge)) {
      step += 4;
      protect += 240 + owner.mag * 4;;
    }
    owner.spsum -= 256;
    updates.add(new RunUpdate(l('[0]防御力大幅上升', 'sklIrond') + Dt.s_iron, owner, owner));
  }
  int postDefend(int dmg, Plr caster, ondmg(Plr caster, Plr target, int dmg, R r, RunUpdates updates), R r, RunUpdates updates) {
    if (dmg > 0) {
      if (dmg <= protect) {
        dmg = 1;
        protect -= dmg - 1;
      } else {
        dmg = dmg - protect;
        destroy(caster, updates);
      }
      return dmg;
    }
    return 0;
  }
  int protect = 0;
  int step = 0;
  void postAction(R r, RunUpdates updates) {
    step --;
    if (step == 0) {
      destroy(null, updates);
      owner.spsum -= 128;
    }
  }
  void updateState(Plr p) {
    owner.attract *= 1.12;
  }
  // meta
  int get metaType => step;
  void destroy(Plr caster, RunUpdates updates) {
    onPostDefend.unlink();
    onPostAction.unlink();
    onUpdateState.unlink();
    owner.meta.remove(Dt.iron);
    owner.updateStates();
    if (caster != null) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(
                     l('[1]的[铁壁]被打消了', 'sklIronCancel'), caster, owner));
    } else {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(
                     l('[0]从[铁壁]中解除', 'sklIronEnd'), owner, owner));
    }
    step = 0;
    protect = 0;
  }
  Plr get target => owner;

}
