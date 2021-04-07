part of md5;

abstract class IAddPlr implements Plr {
  Plr get owner;
}

abstract class Minion extends Plr implements DieProc, IAddPlr {
  DieImpl onOwnerDie;

  Minion(String baseName, [String clanName, String sglName])
      : super(baseName, clanName, sglName) {
    onOwnerDie = new DieImpl(this);
  }

  // on owner die
  bool die(int dmg, Plr caster, R r, RunUpdates updates) {
    if (alive) {
      int oldhp = hp;
      hp = 0;
      onDie(oldhp, null, r, updates);
    }
    onOwnerDie.unlink();
    return false;
  }

  String getDieMessage() {
    return l('[1]消失了', 'minionDie');
  }
}

class Plr implements IPlr {
  static Random _rng = new Random();

  static int compare(Plr p1, Plr p2) {
    int t = p1.sortInt - p2.sortInt;
    if (t != 0) {
      return t;
    }
    return p1.idName.compareTo(p2.idName);
  }

  String baseName;
  String clanName;
  String sglName;

  String weaponName;

  /// for sorting and indexing
  String idName;
  String fullName; //idname+weapon
  String dispName;

  Grp group;

  /// same as group unless charmed
  Grp allyGroup;

  int sortInt = 0;

  int atk;
  int def;
  int spd;
  int agl;
  int mag;
  int mdf;
  int itl;

  int hp;
  int maxhp;
  int mp;

  // deprecated
  // int sneak = 0;
  double atboost = 1.0;

  List<Skill> skills = <Skill>[];
  List<Skill> sortedSkills;

  ActionSkl dftAct;
  List<ActionSkl> actions = <ActionSkl>[];

  Weapon weapon;

  final Map<String, IMeta> meta = new LinkedHashMap<String, IMeta>();
  MList<UpdateStateEntry> updatestates = new MList<UpdateStateEntry>();
  MList<PreStepEntry> presteps = new MList<PreStepEntry>();
  MList<PreActionEntry> preactions = new MList<PreActionEntry>();
  MList<PostActionEntry> postactions = new MList<PostActionEntry>();
  MList<PreDefendEntry> predefends = new MList<PreDefendEntry>();
  MList<PostDefendEntry> postdefends = new MList<PostDefendEntry>();
  MList<PostDamageEntry> postdamages = new MList<PostDamageEntry>();
  MList<DieEntry> dies = new MList<DieEntry>();
  MList<KillEntry> kills = new MList<KillEntry>();

  /// return true when it's prevented
  bool immune(String key, R r) {
    return false;
  }

  bool frozen = false;

  bool get active => hp > 0 && !frozen;

  bool get dead => hp <= 0;

  bool get alive => hp > 0;

  bool mpReady(R r) {
    if (hp <= 0 || frozen) {
      return false;
    }
    int reqmp = r.r3x3;
    if (mp >= reqmp) {
      mp -= reqmp;
      return true;
    }
    return false;
  }

  List<int> attr = [];

  R rc4;

  /// for upgrade
  List<int> ss0 = <int>[];
  List<int> ss = <int>[];
  List<int> sglss = <int>[];

  Plr(this.baseName, [this.clanName, this.sglName, this.weaponName]) {
    // removed
  }

  /// upgrade leader from team member
  void upgrade(List<int> ssx) {
    if (ssx.length == ss.length) {
      for (int i = 7; i < ss.length; ++i) {
        if (ssx[i - 1] == ss0[i] && ssx[i] > ss[i]) {
          ss[i] = ssx[i];
        }
      }
      if (baseName == clanName) {
        for (int i = 5; i < ss.length; ++i) {
          if (ssx[i - 2] == ss0[i] && ssx[i] > ss[i]) {
            ss[i] = ssx[i];
          }
        }
      }
    }
  }

  buildAsync() async {
    if (weapon != null) {
      weapon.preUpgrade();
    }
    initRawAttr();

    initLists();

    initSkills(ss.sublist(64), ss0.sublist(64));

    if (weapon != null) {
      weapon.postUpgrade();
    }

    addSkillsToProc();

    initValues();
  }

  void initRawAttr() {
    // removed
  }

  static int getMiddle(List<int> input) {
    List<int> x = [
      Math.min(input[0], input[1]),
      input[2],
      Math.min(input[3], input[4])
    ];
    x.sort();
    return x[1];
  }

  void initLists() {
    actions.clear();
    meta.clear();
    updatestates.clear();
    presteps.clear();
    preactions.clear();
    postactions.clear();
    predefends.clear();
    postdefends.clear();
    postdamages.clear();
    dies.clear();
    kills.clear();
  }

  void createSkills() {
    dftAct = new SklAttack(this);

    skills.add(new SklFire()); // 0
    skills.add(new SklIce()); // 1
    skills.add(new SklThunder()); // 2
    skills.add(new SklQuake()); // 3
    skills.add(new SklAbsorb()); // 4
    skills.add(new SklPoison()); // 5
    skills.add(new SklRapid()); // 6
    skills.add(new SklCritical()); // 7
    skills.add(new SklHalf()); // 8
    skills.add(new SklExchange()); // 9
    skills.add(new SklBerserk()); // 10
    skills.add(new SklCharm()); // 11
    skills.add(new SklHaste()); // 12
    skills.add(new SklSlow()); // 13
    skills.add(new SklCurse()); // 14

    skills.add(new SklHeal()); // 15
    skills.add(new SklRevive()); // 16
    skills.add(new SklDisperse()); // 17
    skills.add(new SklIron()); // 18

    skills.add(new SklCharge()); // 19
    skills.add(new SklAccumulate()); // 20

    skills.add(new SklAssassinate()); // 21

    skills.add(new SklSummon()); // 22
    skills.add(new SklClone()); // 23
    skills.add(new SklShadow()); // 24

    skills.add(new SklDefend()); // 25
    skills.add(new SklProtect()); // 26
    skills.add(new SklReflect()); // 27
    skills.add(new SklReraise()); // 28
    skills.add(new SklShield()); // 29
    skills.add(new SklCounter()); // 30
    skills.add(new SklMerge()); // 31
    skills.add(new SklZombie()); // 32
    skills.add(new SklUpgrade()); // 33
    skills.add(new SklHide()); // 34

    skills.add(new SklVoid());
    skills.add(new SklVoid());
    skills.add(new SklVoid());
    skills.add(new SklVoid());
    skills.add(new SklVoid());
  }

  void initSkills(List<int> list, List<int> original) {
    int i = 0, j = 0;
    // removed
    for (; i < sortedSkills.length; ++i) {
      Skill skl = sortedSkills[i];
      skl.init(this, 0);
    }
  }

  void addSkillsToProc() {
    for (int i = 0; i < sortedSkills.length; ++i) {
      Skill skl = sortedSkills[i];
      if (skl.level > 0 && skl is ActionSkl) {
        actions.add(skl);
      }
    }
    // boost actions
    if (actions.length > 0) {
      for (var i = actions.length - 1; i >= 0; --i) {
        var act = actions[i];
        if (!act.boosted) {
          act.level *= 2;
          act.boosted = true;
          break;
        }
      }
    }
    // boost passive
    void boostPassive(Skill skl, int b1, int b2) {
      if (skl.level > 0 && !skl.boosted) {
        int up = min(b1,b2);
        skl.level += min(up, skl.level);
        skl.boosted = true;
      }
    }
    if (sortedSkills.length >= 16) {
      boostPassive(sortedSkills[14], ss[60], ss[61]);
      boostPassive(sortedSkills[15], ss[62], ss[63]);
    }
    for (int i = 0; i < skills.length; ++i) {
      Skill skl = skills[i];
      if (skl.level > 0) {
        skl.addToProcs();
      }
    }
  }

  void initValues() {
    updateStates();
    hp = maxhp;
    mp = itl ~/ 2;
  }

  void updateStates() {
    atk = attr[0];
    def = attr[1];
    spd = attr[2] + 160;
    agl = attr[3];
    mag = attr[4];
    mdf = attr[5];
    itl = attr[6];
    maxhp = attr[7];

    calcAttrSum();

    allyGroup = group;
    atboost = 1.0;

    frozen = false;

    for (UpdateStateEntry ude in updatestates) {
      ude.updateState(this);
    }
  }

  int attrsum = 0;
  int atksum = 0;
  int allsum = 0;
  double attract = 0x8000;

  void calcAttrSum() {
    attrsum = 0;
    for (int i = 0; i < 7; ++i) {
      attrsum += attr[i];
    }
    atksum = (attr[0] - attr[1] + attr[2] + attr[4] - attr[5]) * 2 +
        attr[3] +
        attr[6];
    allsum = attrsum * 3 + attr[7];
    attract = 0x8000;
  }

  // start action when spsum >= 2048
  int spsum = 0;

  void step(R r, RunUpdates updates) {
    if (hp <= 0) {
      return;
    }
    int stp = spd * (r.r3);
    if (presteps.isNotEmpty) {
      for (PreStepEntry entry in presteps) {
        stp = entry.preStep(stp, r, updates);
      }
    }
    spsum += stp;
    if (spsum > 2048) {
      spsum -= 2048;
      action(r, updates);
    }
  }

  ActionSkl acting;

  void action(R r, RunUpdates updates) {
    List<PlrScore> targets;
    bool smart = r.r63 < itl;
    int reqMp = 0;
    ActionSkl skl = preAction(smart, r, updates);

    if (frozen) {
      // allow preAction to unfreeze
      return;
    }

    if (skl == null) {
      reqMp = r.r15 + 8;
      if (mp >= reqMp) {
        // select skill
        for (ActionSkl s in actions) {
          if (!s.prob(r, smart)) continue;
          targets = s.select(smart, r);
          if (targets == null) continue;
          skl = s;
          break;
        }
        mp -= reqMp;
      }
    }
    if (skl == null) {
      skl = dftAct;
    }
    if (targets == null) {
      // preAction choosed skil
      targets = skl.select(smart, r);
    }
    acting = skl;
    skl.act(targets, smart, r, updates);
    acting = null;

    if (r.r127 < itl + 64) {
      // recover mp
      mp += 16;
    }

    postAction(r, updates);
    if (pendingClearStates) {
      clearStates(null, updates);
    }
  }

  bool pendingClearStates = false;

  void clearStates(Plr caster, RunUpdates updates) {
    if (postAcioning) {
      pendingClearStates = true;
      return;
    }
    pendingClearStates = false;
    for (String key in meta.keys.toList()..sort()) {
      if (meta[key].metaType < 0) {
        meta[key].destroy(caster, updates);
        meta.remove(key);
      }
    }
  }

  ActionSkl preAction(bool smart, R r, RunUpdates updates) {
    ActionSkl skl;
    for (PreActionEntry entry in preactions) {
      skl = entry.preAction(skl, smart, r, updates);
    }
    return skl;
  }

  bool postAcioning = false;

  void postAction(R r, RunUpdates updates) {
    postAcioning = true;
    updates.add(RunUpdate.newline);
    for (PostActionEntry entry in postactions) {
      entry.postAction(r, updates);
    }
    postAcioning = false;
  }

  double preDefend(double atp, bool isMag, Plr caster, OnDamage ondmg, R r,
      RunUpdates updates) {
    for (PreDefendProc proc in predefends) {
      atp = proc.preDefend(atp, isMag, caster, this, ondmg, r, updates);
      if (atp == 0.0) {
        return 0.0;
      }
    }
    return atp;
  }

  int postDefend(int dmg, Plr caster, OnDamage ondmg, R r, RunUpdates updates) {
    for (PostDefendProc proc in postdefends) {
      dmg = proc.postDefend(dmg, caster, ondmg, r, updates);
    }
    return dmg;
  }

  int attacked(double atp, bool isMag, Plr caster, OnDamage ondmg, R r,
      RunUpdates updates) {
    atp = preDefend(atp, isMag, caster, ondmg, r, updates);
    if (atp == 0.0) {
      return 0;
    }
    int accure;
    int dodgeval;
    if (isMag) {
      dodgeval = mdf + agl;
      accure = caster.mag + caster.agl;
    } else {
      dodgeval = def + agl;
      accure = caster.atk + caster.agl;
    }
    if (active && Alg.dodge(accure, dodgeval, r)) {
      updates.add(new RunUpdate(
          l('[0][回避]了攻击', 'dodge'), this, caster, null, null, 20));
      return 0;
    }
    return defend(atp, isMag, caster, ondmg, r, updates);
  }

  int defend(double atp, bool isMag, Plr caster, OnDamage ondmg, R r,
      RunUpdates updates) {
    num dfp = Alg.getDf(this, isMag, r);
    int dmg = (atp / dfp).ceil();
    dmg = postDefend(dmg, caster, ondmg, r, updates);
    return damage(dmg, caster, ondmg, r, updates);
  }

  int damage(int dmg, Plr caster, OnDamage ondmg, R r, RunUpdates updates) {
    if (dmg < 0) {
      int oldhp = hp;
      hp -= dmg;
      if (hp > maxhp) {
        hp = maxhp;
      }
      updates.add(new RunUpdate(l('[1]回复体力[2]点', 'recover'), caster,
          new HPlr(this, oldhp), new HRecover(-dmg)));
      return 0;
    }
    String msg = l('[1]受到[2]点伤害', 'damage');
    if (dmg == 0) {
      msg = msg.replaceFirst('1', '0');
      updates.add(
          new RunUpdate(msg + Dt.s_dmg0, this, this, new HDamage(0), null, 10));
      return 0;
    }
    int oldhp = hp;
    hp -= dmg;
    if (hp <= 0) {
      hp = 0;
    }
    if (dmg >= 160) {
      msg = msg + Dt.s_dmg160;
    } else if (dmg >= 120) {
      msg = msg + Dt.s_dmg120;
    }
    RunUpdate update = new RunUpdate(
        msg, caster, new HPlr(this, oldhp), new HDamage(dmg), null, dmg);
    if (dmg > 250) {
      update.delay0 = 1500;
    } else {
      update.delay0 = 1000 + dmg * 2;
    }

    updates.add(update);
    ondmg(caster, this, dmg, r, updates);
    return onDamaged(dmg, oldhp, caster, r, updates);
  }

  int onDamaged(int dmg, int oldhp, Plr caster, R r, RunUpdates updates) {
    for (PostDamageEntry entry in postdamages) {
      entry.postDamage(dmg, caster, r, updates);
    }
    if (hp <= 0) {
      onDie(oldhp, caster, r, updates);
      return oldhp;
    } else {
      return dmg;
    }
  }

  String getDieMessage() {
    return l('[1]被击倒了', 'die');
  }

  void onDie(int oldhp, Plr caster, R r, RunUpdates updates) {
    updates.add(RunUpdate.newline);
    updates.add(
        new RunUpdate(getDieMessage(), caster, new DPlr(this), null, null, 50));
    for (DieEntry entry in dies) {
      if (entry.die(oldhp, caster, r, updates)) {
        break;
      }
    }
    if (hp > 0) {
      return;
    }

    group.die(this);
    // if battle ended, error will be thrown so kill proc won't be called

    if (caster != null && caster.alive) {
      caster.kill(this, r, updates);
    }
  }

  void revive(R r, RunUpdates updates) {
    group.revive(this);
  }

  void kill(Plr target, R r, RunUpdates updates) {
    for (KillEntry entry in kills) {
      if (entry.kill(target, r, updates)) {
        break;
      }
    }
  }

  Plr selectEnemy(R r) {
    return r.pickSkipRange(allyGroup.f.alives, allyGroup.alives);
  }

  Plr selectAlly(R r) {
    return r.pickSkip(allyGroup.alives, this);
  }

  String toString() {
    return '[$dispName]';
  }

  String toGroupString() {
    return '[$sglName]';
  }

  String toDetail() {
    return '$idName\t$dispName\t$sglName\t$fullName\t$maxhp';
  }

  String getScoreStr() {
    if (allsum > 1200) {
      int score = (allsum - 1200) ~/ 60;
      if (score > 2) {
        return '2';
      } else {
        return score.toString();
      }
    }
    return '';
  }
}
