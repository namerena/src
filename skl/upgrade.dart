part of md5;

class SklUpgrade extends Skill implements PostDamageEntry, UpdateStateProc, IMeta {

  SklUpgrade(){
    onUpdateState = new UpdateStateImpl(this);
  }

  void addToProcs(){
    owner.postdamages.add(this);
  }

  void postDamage(int dmg, Plr caster, R r, RunUpdates updates) {
    if (level <= 0 || onUpdateState.list != null) {
      return;
    }
    int minhp = 16;
    if (level > 63) {
      minhp += level - 63;
    }
    if (owner.alive && owner.hp < minhp + r.r63 && r.r63 < level) {
      owner.meta[Dt.upgrade] = this;
      owner.updatestates.add(onUpdateState);
      owner.updateStates();
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdate(
          l('[0]做出[垂死]抗争', 'sklUpgrade'), owner, owner, null, null, 60, 1500));
      updates.add(new RunUpdate(
               l('[0]所有属性上升', 'sklUpgraded') + Dt.s_upgrade, owner, owner));
      owner.spsum += 400;
    }
  }

  int get metaType => 1;
  Plr get target => owner;
  void destroy(Plr caster, RunUpdates updates) {
    owner.meta.remove(Dt.upgrade);
    onUpdateState.unlink();
    owner.updateStates();
    if (owner.alive) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(
                l('[1]的[垂死]属性被打消', 'sklUpgradeCancel'), caster, owner));
    }
  }


  UpdateStateImpl onUpdateState;
  void updateState(Plr p) {
    owner.atk += 30;
    owner.def += 30;
    owner.agl += 30;
    owner.mag += 30;
    owner.mdf += 30;
    owner.spd += 20;
    owner.itl += 20;
  }
}
