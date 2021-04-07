part of md5;

// l('新冠病毒','bossName_covid')

class BossCovid extends PlrBoss {
  BossCovid(String baseName, String clanName) : super(baseName, clanName);

  List<int> get appendAttr => const  [10, 9, 0, 12, 0, 12, 0, 60];

  List<String> get immuned => [Dt.charm, Dt.berserk, Dt.exchange];

  void createSkills() {
    dftAct = new SklCovidAttack(this);
    skills.add(new SklCovidDefend());
  }
}


class CovidMeta implements IMeta {
  Plr  target;
  // not treated as negative, can't be healed
  int get metaType => 0;

  bool recovered = false;

  Set<int> mutations = new Set();

  CovidMeta(this.target,int mutation) {
    addMutation(mutation);
  }

  bool hasMutation(int mutation) => mutations.contains(mutation);

  addMutation(int mutation) => mutations.add(mutation);

  void destroy(Plr caster, RunUpdates updates){}
}

bool _hasMask(Plr p) {
  return (p.weaponName != null && (p.weaponName.endsWith(Dt.mask) || p.weaponName.endsWith(Dt.maskz)));
}

class CovidState extends ActionSkl implements PreActionProc, PostActionProc {
  final Plr owner;
  final Plr target;

  int days = 0;
  int mutation;

  CovidMeta meta;

  CovidState(this.owner, this.target, this.mutation) {
    onPostAction = new PostActionImpl(this);
    onPreAction = new PreActionImpl(this);
  }


  PostActionImpl onPostAction;
  PreActionImpl onPreAction;

  void postAction(R r, RunUpdates updates) {
    if (target.alive && days > 1) {
      double atpp = Alg.getAt(target, true, r) + mutation * 80;
      int dfp = Alg.getDf(target, true, r);
      int dmg = (atpp/dfp).ceil() ;
      updates.add(new RunUpdate(l('[1][肺炎]发作','sklCovidDamage'), owner, target));

      int damaged = target.damage(dmg, owner, Skill.onDamage, r, updates);

      if (damaged > 0 && owner.alive) {
        int healedhp = dmg >> 1;
        if (owner.hp >= owner.maxhp) {
          healedhp = (healedhp >> 2) + 1;
        }
        if (healedhp > damaged) {
          healedhp = damaged;
        }
        int oldhp = owner.hp;
        owner.hp += healedhp;
        updates.add( new RunUpdate(l('[1]回复体力[2]点','recover'), owner, new HPlr(owner, oldhp), new HRecover(healedhp)));
      }
    }
    if (days > 6) {
      this.destroy(target, updates);
    }
  }

  void add(R r, RunUpdates updates) {
    meta = target.meta[Dt.covid] as CovidMeta;
    if (meta != null) {
      meta.addMutation(mutation);
    } else {
      meta = new CovidMeta(target, mutation);
      target.meta[Dt.covid] = meta;
    }

    target.postactions.add(onPostAction);
    target.preactions.add(onPreAction);
    target.updateStates();
  }
  void destroy(Plr caster, RunUpdates updates) {
    unlink();

    meta.recovered = true;

    onPostAction.unlink();
    onPreAction.unlink();
    target.updateStates();
  }

  @override
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    if (days == 0 || r.r255 > target.itl) {
      days+=r.r3;
      // spread
      for (int i = 0; i < 5; ++i) {
        Plr p = r.pick(owner.group.f.alives);
        if (p != target && p != owner) {
          CovidMeta meta = p.meta[Dt.covid] as CovidMeta;
          if (meta == null || !meta.hasMutation(mutation)) {
            if (p.group == target.group) {
              if (talk(p, r, updates)) {

              }
            } else {
              attack(p, r, updates);
            }
            return;
          }
        }
      }
    }
    days+=r.r3;

    if (days > 2) {
      updates.add(new RunUpdate(l('[1]在重症监护室无法行动','sklCovidICU'), owner, target));
    } else {
      updates.add(new RunUpdate(l('[1]在家中自我隔离','sklCovidStayHome'), owner, target));
    }
  }

  bool talk(Plr toInfect, R r, RunUpdates updates) {
    updates.add(new RunUpdate(l('[0]和[1]近距离接触','sklCovidInfect'), target, toInfect));
    int itlMask = toInfect.itl;
    if (_hasMask(toInfect)) {
      itlMask += 192;
    } else {
      itlMask >>= 1;
    }
    if (r.r255 < itlMask) {
      updates.add(new RunUpdate(l('但[1]没被感染','sklCovidPrevent'), target, toInfect));
      return false;
    } else {
      return CovidState.newState(owner, toInfect, mutation, r, updates);
    }
  }

  void attack(Plr toInfect, R r, RunUpdates updates) {
    double atp = Alg.getAt(target, false, r) ;
    updates.add(new RunUpdate(l('[0]发起攻击','sklAttack'), target, toInfect));
    toInfect.attacked(atp, false, owner, onDamage, r, updates) ;
  }
  void onDamage(Plr caster, Plr toInfect, int dmg, R r, RunUpdates updates) {
    CovidState.newState(owner, toInfect, mutation, r, updates);
  }

  @override
  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates) {
    if (r.c25) {
      // mutate
      mutation = r.r127;
      this.meta.addMutation(mutation);
      // updates.add(new RunUpdate(l('[1]所感染的病毒发生变异','sklCovidMutate'), owner, target));
    }

    return this;
  }

  static bool newState(Plr caster, Plr target, int mutation, R r, RunUpdates updates) {
    CovidMeta covidMeta = target.meta[Dt.covid] as CovidMeta;
    if (covidMeta == null || (covidMeta.recovered && !covidMeta.hasMutation(mutation))) {
      CovidState covidState = new CovidState(caster, target, mutation);
      covidState.add(r, updates);
      updates.add(new RunUpdate(l('[1]感染了[新冠病毒]','sklCovidHit'), caster, target));
      for (Plr p in caster.group.f.alives) {
        if (p == target) {
          p.spsum += 2048;
        } else {
          p.spsum -= 256;
        }
      }
      return true;
    }
    return false;
  }
}

class SklCovidDefend extends Skill implements PostDamageEntry {
  void addToProcs(){
    owner.postdamages.add(this);
  }

  void postDamage(int dmg, Plr caster, R r, RunUpdates updates) {
    if (caster.meta[Dt.covid] == null) {
      if (_hasMask(caster) && r.c75) {
        return;
      }
      CovidState.newState(owner, caster, 40, r, updates);
    }
  }
}

class SklCovidAttack extends ActionSkl {

  static void onDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    if (target.meta[Dt.covid] == null && r.r64 < dmg) {
      CovidState.newState(caster, target, 40, r, updates);
    }
  }
  final Plr owner;

  SklCovidAttack(this.owner);

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;
    double atp = Alg.getAt(owner, false, r) ;
    updates.add(new RunUpdate(l('[0]发起攻击','sklAttack'), owner, target));
    target.attacked(atp, false, owner, onDamage, r, updates) ;
  }
}
