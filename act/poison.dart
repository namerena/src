part of md5;

class PoisonState extends PostActionEntry implements IMeta {
  Plr caster;
  final Plr target;
  PoisonState(this.target, this.caster) {
  }
  // nagetive meta
  int get metaType => -1;

  double atp;
  int count = 4;
  void postAction(R r, RunUpdates updates) {
    if (target.alive) {
        double atpp = atp * (1 + (count-1) * 0.1) / count;
        atp -= atpp;
        int dfp = target.mag + 64;
        int dmg = (atpp/dfp).ceil();
        updates.add(new RunUpdate(l('[1][毒性发作]','sklPoisonDamage'), caster, target));
        target.damage(dmg, caster, Skill.onDamage, r, updates);
        --count;
        if (count == 0) {
          destroy(null, updates);
        }
      }

  }

  void add() {
     target.meta[Dt.poison] = this;
     target.postactions.add(this);
   }

  void destroy(Plr caster, RunUpdates updates) {
    target.meta.remove(Dt.poison);
    unlink();
    if (target.alive) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(l('[1]从[中毒]中解除','sklPoisonEnd'), caster, target));
    }
  }
  bool get persist => false;
}

class SklPoison extends ActionSkl {

  static void onDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    if (dmg > 4 && !target.dead) {
      if (target.immune(Dt.poison, r)) {
        return;
      }

      PoisonState poisonState = target.meta[Dt.poison] as PoisonState;
      if (poisonState == null) {
        poisonState = new PoisonState(target, caster);
        poisonState.atp = Alg.getAt(caster, true, r) * 1.2 ;
        poisonState.add();
      } else {
        poisonState.atp += Alg.getAt(caster, true, r) * 1.2;
        poisonState.count = 4;
        poisonState.caster = caster;
      }
      updates.add(new RunUpdate(l('[1][中毒]', 'sklPoisonHit') + Dt.s_poison, caster, target, null, null, 60));

    }
  }


  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    double atp = Alg.getAt(owner, true, r);
    updates.add(new RunUpdate(l('[0][投毒]','sklPoison'), owner, target, null, null, 1));
    target.attacked(atp, true, owner, onDamage, r, updates);
  }
}
