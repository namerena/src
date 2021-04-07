part of md5;

class SklReflect extends Skill implements PreDefendEntry {
  double preDefend(double atp, bool isMag, Plr caster, Plr target, OnDamage ondmg,
      R r, RunUpdates updates) {
    if (caster.dead) {
      return atp;
    }
    if (r.r255 < level && r.c50 && owner.mpReady(r)) {
      double atp2 = Alg.getAt(owner, true, r) * 0.5;
      if (atp2 > atp) atp2 = atp;
      updates.add(new RunUpdate(l('[0]使用[伤害反弹]', 'sklReflect') + Dt.s_reflect, owner, caster, null, null, 20, 1500));
      caster.attacked(atp2, true, owner, ondmg, r, updates);
      owner.spsum -= 480;
      return 0.0;
    }
    return atp;
  }
  void addToProcs(){
    owner.predefends.add(this);
  }
}
