part of md5;

// l('斑鸠','bossName_ikaruga')

class BossIkaruga extends PlrBoss {
  BossIkaruga(String baseName, String clanName) : super(baseName, clanName);

  List<int> get appendAttr => const  [48, 28, 21, 45, 10, 19, 33, 150];

  List<String> get immuned => [Dt.assassinate, Dt.half, Dt.exchange, Dt.poison, Dt.slow, Dt.ice];

  bool immune(String key, R r) {
    if (key == Dt.curse) {
      return false;
    }
    return super.immune(key, r);
  }
  void createSkills() {
    dftAct = new SklAttack(this);

    skills.add(new SklIkarugaDefend());
    skills.add(new SklIkarugaAttack().. level = 48);
  }
}


class SklIkarugaDefend extends Skill implements PostDefendEntry {
  // after curse
  double get sortId => 20000.0;

  int postDefend(int dmg, Plr caster, ondmg(Plr caster, Plr target, int dmg, R r, RunUpdates updates), R r, RunUpdates updates) {
    if (dmg > 0 && (dmg & 1) == 1) {
      updates.add(new RunUpdate(l('[0][吸收]所有奇数伤害','sklIkarugaDefend'), owner, null, null, null, dmg));
      return -dmg;
    }
    return dmg;
  }
  void addToProcs(){
    owner.postdefends.add(this);
  }
}


class SklIkarugaAttack extends ActionSkl {

  int get selCount => 5;
  int get selCountSmart => 6;

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {

    List<IPlr> plrs = [];
    for (int i = 0; i < targets.length; ++i) {
      plrs.add(targets[i].p);
    }
    updates.add(new RunUpdate(l('[0]使用[能量释放]','sklIkarugaAttack'), owner, null, null, plrs.toList(), 1));
    double atp = Alg.getAt(owner, true, r) * 2.5 / (plrs.length + 0.5);
    for (int i = 0; i < plrs.length; ++i) {
      Plr target = plrs[i] as Plr;
      if (target.alive) {
        updates.add(RunUpdate.newline);
        target.defend(atp, true, owner, Skill.onDamage, r, updates);
      }
    }

  }
}
