part of md5;

class SklCounter extends Skill implements PostDamageEntry {
  
  bool pending = false;
  RunUpdates lastupdates;
  Plr lastTarget;
  
  void addToProcs(){
    owner.postdamages.add(this);
  }
  
  void postDamage(int dmg, Plr caster, R r, RunUpdates updates) {
    if (caster.group == owner.allyGroup && r.r63 < owner.itl) {
      return;
    }
    if (lastupdates == updates) {
      if (pending && caster != lastTarget) {
        if (r.r127 < level) {
          lastTarget = caster;
        }
      }
    } else {
      lastupdates = updates;
      if (r.r255 < level) {
        lastTarget = caster;
        pending = true;
        updates.onUpdateEnd.add(onCounter);
      }
    }
  }
  
  void onCounter(R r, RunUpdates updates) {
    pending = false;
    lastupdates = null;
    if (lastTarget.alive && owner.mpReady(r)) {
      double atp = Alg.getAt(owner, false, r);
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdate(l('[0]发起[反击]', 'sklCounter') + Dt.s_counter, owner, lastTarget, null, null, 1));
      lastTarget.attacked(atp, false, owner, Skill.onDamage, r, updates);
    }
  }
}