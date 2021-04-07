part of md5;

class SklRapid extends ActionSkl {
  
  int get selCount => 3;
  int get selCountSmart => 5;
  
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    int round = r.c50 ? 3 : 2;
    if (targets.length > 3) {
      targets = targets.sublist(0, 3);
    }
    for (PlrScore score in targets) {
      // set for hit log
      score.score = 0.0;
    }
    int pos = 0;
    for (num i = 0; i < round; ++i) {
      if (!owner.active) {
        return;
      }
      PlrScore pscore = targets[pos];
      if (pscore.p.dead) {
        i -= 0.5;
      } else {
        double atp = Alg.getAt(owner, false, r) * (0.75 - pscore.score * 0.15);
        pscore.score ++;
        if (i == 0) {
          updates.add(new RunUpdate(l('[0]发起攻击','SklRapid'), owner, pscore.p));
        } else {
          updates.add(new RunUpdate(l('[0][连击]','SklRapidNext'), owner, pscore.p, null, null, 1));
        } 
        int rslt = pscore.p.attacked(atp, false, owner, Skill.onDamage, r, updates);
        if (rslt <= 0) {
          return;
        }
        updates.add(RunUpdate.newline);
      }

      pos = (pos + r.r3) % targets.length;
    }

  }
}