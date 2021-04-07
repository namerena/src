part of md5;

// l('马里奥','bossName_mario')

class BossMario extends PlrBoss {
  BossMario(String baseName, String clanName)
      : super(baseName, clanName);

  List<int> get appendAttr => const  [0, 38, 31, 46, 28, 18, 15, 69];

  void updateStates() {
    super.updateStates();
    if (grow > 0) {
      atboost *= 1.5;
    }
  }

  List get immunedx => [];
  List<String> get immuned => [Dt.assassinate];

  bool immune(String key, R r) {
    if (key == Dt.disperse) {
      return false;
    }
    return super.immune(key, r);
  }

  int grow = 0;

  SklFire sklFire;
  SklMarioGet sklGet;
  SklMarioReraise sklReRaise;
  void createSkills() {
    dftAct = new SklSimpleAttack(this);

    sklFire = new SklFire();
    sklGet = new SklMarioGet(this);

    skills.add(sklGet);
    skills.add(sklFire);

    sklReRaise = new SklMarioReraise(this, 3);
    skills.add(sklReRaise);
  }
}

class SklMarioGet extends ActionSkl  implements IMeta {
  int get metaType => 1;
  Plr get target => mario;

  BossMario mario;
  SklMarioGet(this.mario) {
    owner = mario;
    level = 63;
  }
  void init(Plr owner, int l) {}

  bool prob(R r, bool smart) {
    if (mario.grow >= 2) {
      if (mario.sklReRaise.life >= 2) {
        return false;
      }
      return r.r255 < 7;
    }
    return r.c50;
  }

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    mario.meta[Dt.mario] = this;
    mario.grow++;
    if (mario.grow == 1) {
      updates.add(new RunUpdate(l('[0]得到[蘑菇]', 'bossMarioGrow10'), owner));
      mario.updateStates();
      updates.add(new RunUpdate(l('[0]攻击力上升', 'bossMarioGrow11'), owner));
    } else if (mario.grow == 2) {
      updates.add(new RunUpdate(l('[0]得到[火焰花]', 'bossMarioGrow20'), owner));
      mario.sklFire.level = 120;
      updates.add(new RunUpdate(l('[0]学会[火球术]', 'bossMarioGrow21'), owner));
    } else {
      updates.add(new RunUpdate(l('[0]得到[奖命蘑菇]', 'bossMarioGrow30'), owner));
      mario.sklReRaise.life ++;
      updates.add(new RunUpdate(
               l('[0]还剩[2]条命', 'bossMarioLife'), owner, null, mario.sklReRaise.life));
    }
    mario.spsum += 2000;
  }

  void destroy(Plr caster, RunUpdates updates){
    mario.meta.remove(Dt.mario);
    mario.sklFire.level = 0;
    mario.grow = 0;
    mario.updateStates();
  }

}

class SklMarioReraise extends Skill implements DieEntry {
  @override
  double get sortId => 10.0;

  int life;

  SklMarioReraise(Plr mario, this.life) {
    owner = mario;
  }
  void init(Plr owner, int l) {}

  bool die(int dmg, Plr caster, R r, RunUpdates updates) {
    life--;
    if (life > 0) {
      owner.clearStates(null, updates);

      restore(updates);

      updates.add(
          new RunUpdate(l('[0]满血复活', 'bossMarioRevive'), new HPlr(owner, 0))..delay0 = 3000);
      updates.add(new RunUpdate(
          l('[0]还剩[2]条命', 'bossMarioLife'), owner, null, life));

      afterReraise(r, updates);

      return true;
    }
    return false;
  }

  void restore(RunUpdates updates) {
    owner.hp = owner.maxhp;
    (owner as BossMario).sklGet.destroy(null, updates);
  }

  void afterReraise(R r, RunUpdates updates) {

  }

  void addToProcs() {
    owner.dies.add(this);
  }
}
