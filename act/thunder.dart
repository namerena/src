part of md5;

class SklThunder extends ActionSkl {
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    updates.add(new RunUpdate(l('[0]使用[雷击术]','sklThunder'), owner, target, null, null, 1));

    int count = 3 + r.r3;
    int agl = 100 + owner.agl;
    bool hit = false;
    for (int i = 0; i < count; ++i) {
      if (owner.active && target.alive) {
        updates.add(RunUpdate.newline);
        if (target.active && Alg.dodge(agl, target.mdf + target.agl, r)) {
          if (hit) {
            updates.add(new RunUpdate(l('[0][回避]了攻击','sklThunderEnd'), target , owner));
          } else {
            updates.add(new RunUpdate(l('[0][回避]了攻击','dodge'), target , owner));
          }
          return;
        }
        agl -= 10;
        double atp = Alg.getAt(owner, true, r) * 0.36;//0.3;
        int pos = updates.updates.length;
        if (target.defend(atp, true, owner, Skill.onDamage, r, updates) > 0) {
          hit = true;
        }
        updates.updates[pos].delay0 = 300;
      }
    }
  }
}
