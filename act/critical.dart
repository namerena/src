part of md5;

class SklCritical extends ActionSkl {
  SklCritical();

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;
    double atp = Alg.getAt(owner, false, r) * 1.15;
    double atp2 = Alg.getAt(owner, false, r) * 1.2;
    if (atp2 > atp) {
      atp = atp2;
    }
    atp2 = Alg.getAt(owner, false, r) * 1.25;
    if (atp2 > atp) {
      atp = atp2;
    }
    updates.add(new RunUpdate(l('[0]发动[会心一击]','sklCritical'), owner, target, null, null, 1));
    target.attacked(atp, false, owner, Skill.onDamage, r, updates);
  }
}
