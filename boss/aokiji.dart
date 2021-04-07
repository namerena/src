part of md5;

// l('青雉','bossName_aokiji')

class BossAokiji extends PlrBoss {
  BossAokiji(String baseName, String clanName) : super(baseName, clanName);

  List<int> get appendAttr => const  [40, 30, 40, 10, 35, 4, 40, 96];

  void createSkills() {
    dftAct = new SklAttack(this);

    skills.add(new SklAokijiDefend());
    skills.add(new SklAokijiIceAge().. level = 70);
    skills.add(new SklIce().. level = 80);
  }
}


class SklAokijiDefend extends Skill implements PostDefendEntry {
  int postDefend(int dmg, Plr caster, ondmg(Plr caster, Plr target, int dmg, R r, RunUpdates updates), R r, RunUpdates updates) {
    if (dmg > 0 && ondmg == SklIce.onDamage) {
      updates.add(new RunUpdate(l('[0][吸收]所有冰冻伤害','sklAokijiDefend'), owner, null, null, null, dmg));
      return -dmg;
    } else if (dmg > 0 && ondmg == SklAttack.onNormalDamage) {
      dmg = 0;
    }
    return dmg;
  }
  void addToProcs(){
    owner.postdefends.add(this);
  }
}


class SklAokijiIceAge extends ActionSkl {

  int get selCount => 5;
  int get selCountSmart => 6;

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {

    List<IPlr> plrs = [];
    for (int i = 0; i < targets.length; ++i) {
      plrs.add(targets[i].p);
    }
    updates.add(new RunUpdate(l('[0]使用[冰河时代]','sklAokijiIceAge'), owner, null, null, plrs.toList(), 1));
    double atp = Alg.getAt(owner, true, r) * 2.5 / (plrs.length + 0.5);
    for (int i = 0; i < plrs.length; ++i) {
      Plr target = plrs[i] as Plr;
      if (target.alive) {
        updates.add(RunUpdate.newline);
        target.attacked(atp, true, owner, SklIce.onDamage, r, updates);
      }
    }

  }
}
