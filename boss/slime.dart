part of md5;

// l('史莱姆','bossName_slime')

class BossSlime extends PlrBoss {
  BossSlime(String baseName, String clanName)
      : super(baseName, clanName);
  int level = 0;

  List<int> get appendAttr => const  [6, 21, 5, 19, 38, 21, 12, 62];

  List<String> get immunedx => [];
  List<String> get immuned => [Dt.poison];

  void createSkills() {
    dftAct = new SklSimpleAttack(this);

    skills.add(new SklSlimeSpawn());
  }
}

class BossSlime2 extends BossSlime implements IAddPlr{
  BossSlime owner;
  BossSlime2(this.owner, String baseName, String clanName)
      : super(baseName, clanName) {
    idName = MinionCount.getMinionName(owner);
    fixattr();
  }
  List<int> get appendAttr => null;

  void fixattr(){

    if (level == 1) {
      for (int i = 0; i < 10; ++i) {
        ss[i] = 16;
      }
      // middle slime
      for (int i = 10; i < 50; ++i) {
         ss[i] |= 16;
      }
    } else {
      // small slime
      for (int i = 0; i < 10; ++i) {
         ss[i] = -5;
      }
      for (int i = 10; i < 50; ++i) {
        ss[i] |= 32;
      }
    }

  }

  bool immune(String key, R r) {
    return false;
  }

  void createSkills() {
    level = owner.level + 1;
    dftAct = new SklAttack(this);
    if (level == 1) {
      // middle slime
      skills.add(new SklSlimeSpawn());
    } else {
      // small slime
      skills.add(new SklHalf()..level = 32);
      skills.add(new SklHeal()..level = 32);
    }
  }
}

class SklSlimeSpawnState extends IMeta {
  final Plr target;
  SklSlimeSpawnState(this.target);
  int get metaType => 0;
}

class SklSlimeSpawn extends Skill implements DieEntry {
  double get sortId => 0.0;

  SklSlimeSpawn();

  bool die(int dmg, Plr caster, R r, RunUpdates updates) {

    owner.meta[Dt.corpose] = new SklSlimeSpawnState(owner);

    updates.add(RunUpdate.newline);
    updates.add(new RunUpdate(l('[0][分裂]','sklSlimeSpawn'), owner));

    BossSlime2 child1 = new BossSlime2(owner as BossSlime, owner.baseName, owner.clanName);
    child1.group = owner.group;
    child1.build();
    child1.spsum = r.r255 * 4;
    owner.group.addNew(child1);

    BossSlime2 child2 = new BossSlime2(owner as BossSlime, owner.baseName, owner.clanName);
    child2.group = owner.group;
    child2.build();
    child2.spsum = r.r255 * 4;
    owner.group.addNew(child2);

    updates.add(new RunUpdate(l('分成了[0] 和  [1]','sklSlimeSpawned'), new HPlr(child1, child1.hp), new HPlr(child2, child2.hp)));

    return false;
  }
  void addToProcs(){
    owner.dies.add(this);
  }
}
