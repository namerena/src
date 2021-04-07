part of md5;

// l('尤里','bossName_yuri')

class BossYuri extends PlrBoss {
  BossYuri(String baseName, String clanName)
      : super(baseName, clanName);

  List<int> get appendAttr => const  [26, 31, 46, 9, 40, 5, 32, 24];

  List<String> get immunedx => [];
  List<String> get immuned => [];

  void createSkills() {
    dftAct = new SklSimpleAttack(this);

    skills.add(new SklYuriControl(this)..level = 256);
    skills.add(new SklDefend()..level = 48);
    skills.add(new SklReflect()..level = 48);
  }
}



class SklYuriControl extends SklCharm {
  Plr yuri;
  SklYuriControl(this.yuri);

  bool validTarget(Plr p,  bool smart) {
    return (p.group != owner.allyGroup && p != owner && !p.meta.containsKey(Dt.charm));
  }


  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    updates.add(new RunUpdate(l('[0]使用[心灵控制]', 'sklYuriControl'), owner, target, null, null, 1));

    int step = target.group.initPlayers.length;;
    if (step < 3) {
      step = 3;
    }
    CharmState charmState = target.meta[Dt.charm] as CharmState;
     if (charmState == null) {
       charmState = new CharmState(owner.allyGroup, target);
       charmState.step = step;
       charmState.add();
     } else {
       charmState.grp = owner.allyGroup;
       charmState.step += step;
     }
     updates.add(new RunUpdate(l('[1]被[魅惑]了', 'sklCharmHit') + Dt.s_charm, owner, target, null, null, 120));
  }
}
