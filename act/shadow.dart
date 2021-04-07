part of md5;

class SklPossess extends ActionSkl {

  void init(Plr owner, int l) {
    this.owner = owner;
    level = l ~/ 2 + 36;
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    updates.add(new RunUpdate(l('[0]使用[附体]','sklPossess'), owner, target));

    if (target.immune(Dt.berserk, r) || (target.active && Alg.dodge(owner.mag, target.mdf, r))) {
       updates.add(new RunUpdate(l('[0][回避]了攻击','dodge'), target, owner, null, null, 20));
       return;
    }
    BerserkState berserkState = target.meta[Dt.berserk] as BerserkState;
    if (berserkState == null) {
      berserkState = new BerserkState(target);
      berserkState.step = 4;
      berserkState.add();
    } else {
      berserkState.step += 4;
    }
    updates.add(new RunUpdate(l('[1]进入[狂暴]状态', 'sklBerserkHit') + Dt.s_berserk, owner, target));

    int oldhp = owner.hp;
    owner.hp = 0;
    owner.onDie(oldhp, null, r, updates);
  }
}

class PlrShadow extends Minion {
  SklShadow skl;
  Plr get owner {
    return skl.owner;
  }
  PlrShadow(SklShadow s) : super('${s.owner.baseName}?${Dt.shadow}', s.owner.clanName, s.owner.sglName) {
    skl = s;
    idName = MinionCount.getMinionName(skl.owner);
  }

  void createSkills() {
    dftAct = new SklAttack(this);
    skills.add(new SklPossess());
  }
  void initRawAttr() {
    super.initRawAttr();
    // slow speed
    //attr[2] = attr[2] - 50;
    // 1/3 HP
    attr[7] ~/= 2;
  }
}

class SklShadow extends ActionSkl {
  SklShadow();

  bool prob(R r, bool smart) {
    if (smart) {
      if (owner.hp < 80) {
        return false;
      }
    }
    return super.prob(r, smart);
  }

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    level = (level * 0.75).ceil();

    updates.add(new RunUpdate(l('[0]使用[幻术]','sklShadow'), owner, null, null, null, 60));

    PlrShadow shadow = new PlrShadow(this);
    shadow.dispName = l('幻影','sklShadowName');
    shadow.group = owner.group;
    owner.dies.add(shadow.onOwnerDie);
    shadow.build();
    if (owner.meta.containsKey(Dt.charge)) {
      shadow.spsum = 2048;
    } else {
      shadow.spsum = -2048;
    }
    owner.group.addNew(shadow);

    updates.add(new RunUpdate(l('召唤出[1]','sklShadowed'), owner, new HPlr(shadow, shadow.hp)));
//    owner.damage(r.r31+32, owner, onDamage, r, updates);
  }

}
