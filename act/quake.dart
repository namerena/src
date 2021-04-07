part of md5;

class SklQuake extends ActionSkl {

  int get selCount => 5;
  int get selCountSmart => 6;

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    int round = r.c50 ? 5 : 4;
    List<IPlr> plrs = [];
    for (int i = 0; i < round && i < targets.length; ++i) {
      plrs.add(targets[i].p);
    }
    updates.add(new RunUpdate(l('[0]使用[地裂术]','sklQuake'), owner, null, null, plrs.toList(), 1));
    for (int i = 0; i < plrs.length; ++i) {
      double atp = Alg.getAt(owner, true, r) * 2.44 / (plrs.length + 0.6);
      Plr target = plrs[i] as Plr;
      if (target.alive) {
        updates.add(RunUpdate.newline);
        target.attacked(atp, true, owner, Skill.onDamage, r, updates);
      }
    }

  }
}
