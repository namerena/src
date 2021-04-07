part of md5;


class SklDisperse extends ActionSkl {
  double scoreTarget(Plr target, bool smart, R r) {
    double score = super.scoreTarget(target, smart, r);
    if (smart && target is Minion && target.hp > 100) {
      score *= 2;
    }
    return score;
  }


  static void onDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    if (dmg > 0) {
       List<String> keys = target.meta.keys.toList();
       keys.sort();
       for (String key in keys) {
         IMeta meta = target.meta[key];
         if (meta.metaType > 0) {
           meta.destroy(caster, updates);
         }
       };
       if (target.mp > 64) {
         target.mp -= 64;
       } else if (target.mp > 32) {
         target.mp = 0;
       } else {
         target.mp -= 32;
       }
    }
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;
    double atp = Alg.getAt(owner, true, r) ;
    updates.add(new RunUpdate(l('[0]使用[净化]','sklDisperse'), owner, target, null, null, 20));

    if (target.immune(Dt.disperse, r)) {
       updates.add(new RunUpdate(l('[0][回避]了攻击','dodge'), target, owner, null, null, 20));
       return;
    }

    // pre cancel Dt.shield
    if (target.meta.containsKey('Dt.shield')) {
      target.meta['Dt.shield'].destroy(owner, updates);
    }
    if (target.meta.containsKey('Dt.iron')) {
      target.meta['Dt.iron'].destroy(owner, updates);
    }
    if (target is Minion) {
      atp *= 2.0;
      target.defend(atp, true, owner, onDamage, r, updates);
    } else {
      target.defend(atp, true, owner, onDamage, r, updates);
    }
  }
}
