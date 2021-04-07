part of md5;

class SklExplode extends ActionSkl {

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    FireState fireState = target.meta[Dt.fire] as FireState;
    if (fireState == null) {
      fireState = new FireState(target);
    }
    double atp = Alg.getAt(owner, true, r) * (4.0  + fireState.fireMag);
    updates.add(new RunUpdate(l('[0]使用[自爆]','sklExplode'), owner, target));
    int oldhp = owner.hp;
    owner.hp = 0;
    target.attacked(atp, true, owner, SklFire.onFire, r, updates);
    owner.onDie(oldhp, null, r, updates);
  }
}

class PlrSummon extends Minion implements PostDamageProc{
  SklSummon skl;
  Plr get owner {
    return skl.owner;
  }
  PlrSummon(SklSummon s) : super('${s.owner.baseName}?${Dt.summon}', s.owner.clanName, s.owner.sglName) {
    skl = s;
    idName = MinionCount.getMinionName(skl.owner);
  }

  void rebuild() {
    initLists();
    addSkillsToProc();
    initValues();
  }

  void initRawAttr() {
    super.initRawAttr();
    attr[7] ~/= 3;
    attr[0] = 0;
    attr[1] = owner.attr[1];
    attr[4] = 0;
    attr[5] = owner.attr[5];
  }

  @override
  void createSkills() {
    dftAct = new SklAttack(this);

    skills.add(new SklFire());
    skills.add(new SklFire());
    skills.add(new SklExplode());
  }

  PostDamageImpl onPostDamage;
  @override
  void initLists(){
    super.initLists();
    if (onPostDamage == null) {
      onPostDamage = new PostDamageImpl(this);
    }
    postdamages.add(onPostDamage);
  }

  bool _postDamaging = false;
  void postDamage(int dmg, Plr caster,R r, RunUpdates updates) {
    _postDamaging = true;
    owner.damage(dmg ~/ 2, caster, Skill.onDamage, r, updates);
    _postDamaging = false;
  }

  /// override this function to solve the case that summoned can die twice
  @override
  bool die(int dmg, Plr caster, R r, RunUpdates updates) {
    if (alive) {
      int oldhp = hp;
      hp = 0;
      if (!_postDamaging) {
        onDie(oldhp, null, r, updates);
      } else {
        // die because owner died, this will be handled later
      }
    }
    onOwnerDie.unlink();
    return false;
  }
}

class SklSummon extends ActionSkl {
  PlrSummon summoned;

  SklSummon();

  bool prob(R r, bool smart) {
    if (smart) {
      if (owner.hp < 80) {
        return false;
      }
    }
    return (summoned == null || summoned.dead) && super.prob(r, smart);
  }

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    updates.add(new RunUpdate(l('[0]使用[血祭]','sklSummon'), owner, null, null, null, 60));

    if (summoned == null) {
      summoned = new PlrSummon(this);
      summoned.dispName = l('使魔','sklSummonName');
      summoned.group = owner.group;
      summoned.build();
    } else {
      summoned.rebuild();
    }
    owner.dies.add(summoned.onOwnerDie);
    summoned.spsum = r.r255 * 4
;

    if (owner.meta.containsKey(Dt.charge)) {
      summoned.onPostDamage.unlink();
      summoned.spsum = 2048;
    }

    owner.group.addNew(summoned);

    updates.add(new RunUpdate(l('召唤出[1]','sklSummoned'), owner, new HPlr(summoned,summoned.hp)));
  }
}
