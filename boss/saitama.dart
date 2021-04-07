part of md5;

// l('一拳超人','bossName_saitama')

class BossSaitama extends PlrBoss {
  BossSaitama(String baseName, String clanName) : super(baseName, clanName);

  List<int> get appendAttr => const  [72, 39, 69, 76, 67, 66, 0, 84];

  List<String> get immunedx => [Dt.half, Dt.exchange];
  List<String> get immuned => [Dt.berserk, Dt.slow, Dt.ice];

  void createSkills() {
    dftAct = new SklSaitama();
    skills.add(dftAct);
  }
}



class SklSaitama extends ActionSkl implements PostDefendProc{

  int turns = 0;

  int damages = 0;
  Set hitters = new Set<Plr>();
  Set minions = new Set<Plr>();

  SklSaitama(){
    onPostDefend = new PostDefendImpl(this);
  }

  PostDefendImpl onPostDefend;

  void addToProcs(){
    owner.postdefends.add(this.onPostDefend);
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    if (damages / (hitters.length + minions.length / 3 + 1) > 255) {
      updates.add(new RunUpdate(l('[0]觉得有点饿','saitamaHungry'), owner, null, null, null, null, 1000, 2000));
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdate(l('[0]离开了战场','saitamaLeave'), owner));
      owner.group.die(owner);
      return;
    }

    if (turns < 10) {
      ++turns;
      return;
    }

    Plr target = targets[0].p;
    double atp = Alg.getAt(owner, false, r) * 12;
    updates.add(new RunUpdate(l('[0]发起攻击','sklAttack'), owner, target));
    target.attacked(atp, false, owner, Skill.onDamage, r, updates);

    for (Plr p in owner.group.f.alives) {
      p.spsum = 0;
    }
    owner.spsum = 1700;
  }

  void destroy(Plr caster, RunUpdates updates) {
    onPostDefend.unlink();
  }

  @override
  int postDefend(int dmg, Plr caster, OnDamage ondmg, R r, RunUpdates updates) {
    if (caster is IAddPlr){
      hitters.add(caster.owner);
      minions.add(caster);
    } else {
      hitters.add(caster);
    }

    damages += dmg;
    return dmg ~/ 100;
  }

}
