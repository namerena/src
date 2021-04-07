part of md5;

class SklHide extends Skill
    implements PostDamageEntry, UpdateStateProc, PreActionProc {
  SklHide() {
    onUpdateState = new UpdateStateImpl(this);
    onPreAction = new PreActionImpl(this);
  }

  void addToProcs() {
    owner.postdamages.add(this);
    owner.preactions.add(this.onPreAction);
  }

  void postDamage(int dmg, Plr caster, R r, RunUpdates updates) {
    if (level <= 0 || onUpdateState.list != null) {
      return;
    }
    if (owner.active && owner.allyGroup.alives.length > 1 && r.r63 < level) {
      owner.updatestates.add(onUpdateState);
      owner.updateStates();
      updates.add(new RunUpdate(
          l('[0]发动[隐匿]', 'sklHide'), owner, owner, null, null, 10));
    }
  }

  PreActionImpl onPreAction;

  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates) {
    if (onUpdateState.list != null) {
      onUpdateState.unlink();
      owner.updateStates();
    }
  }

  UpdateStateImpl onUpdateState;

  void updateState(Plr p) {
    owner.attract /= 10;
    if (this.level > 63) {
      int boostDef = this.level - 63;
      owner.agl += boostDef ;
      owner.def += boostDef ;
      owner.mdf += boostDef ;
    }
  }
}
