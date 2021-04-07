part of md5;

// l('懒癌','bossName_lazy')

class BossLazy extends PlrBoss {
  BossLazy(String baseName, String clanName) : super(baseName, clanName);

  List<int> get appendAttr => const  [0, 88, 10, -20, 0, 50, 0, 120];

  List<String> get immuned => [Dt.assassinate, Dt.half, Dt.curse, Dt.exchange];

  void createSkills() {
    dftAct = new SklLazyAttack(this);
    skills.add(new SklLazyDefend());
  }
}



class LazyState extends ActionSkl implements PreActionProc, UpdateStateProc, IMeta, PostActionProc {
  final Plr owner;
  final Plr target;
  LazyState(this.owner, this.target) {
    onPostAction = new PostActionImpl(this);
    onUpdateState = new UpdateStateImpl(this);
    onPreAction = new PreActionImpl(this);
  }
  // not treated as nagtive, can't be healed
  int get metaType => 0;

  PostActionImpl onPostAction;
  UpdateStateImpl onUpdateState;
  PreActionImpl onPreAction;

  void updateState(Plr p) {
    target.spd ~/= 2;
  }

  void postAction(R r, RunUpdates updates) {
    if (target.alive) {
      double atpp = Alg.getAt(owner, true, r);
      int dfp = Alg.getDf(target, true, r);
      int dmg = (atpp/dfp).ceil();
      updates.add(new RunUpdate(l('[1][懒癌]发作','sklLazyDamage'), owner, target));
      target.damage(dmg, owner, Skill.onDamage, r, updates);
    }
  }

  void add() {
    target.meta[Dt.lazy] = this;
    target.updatestates.add(onUpdateState);
    target.postactions.add(onPostAction);
    target.preactions.add(onPreAction);
    target.updateStates();
  }
  void destroy(Plr caster, RunUpdates updates) {
    unlink();
    target.meta.remove(Dt.lazy);
    onPostAction.unlink();
    onPreAction.unlink();
    onUpdateState.unlink();
    target.updateStates();
  }

  @override
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    beLazy(target, r, updates);
  }

  @override
  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates) {
    if (r.c50) {
      return this;
    }
    return skl;
  }

  static void beLazy(Plr p, R r, RunUpdates updates) {
    int t = r.nextByte();
    if (t < 50) {
      updates.add(new RunUpdate(l('[0]打开了[Steam]','sklLazySkipTurn1'), p));
    } else if (t < 100) {
      updates.add(new RunUpdate(l('[0]打开了[守望先锋]','sklLazySkipTurn2'), p));
    } else if (t < 150) {
      updates.add(new RunUpdate(l('[0]打开了[文明6]','sklLazySkipTurn3'), p));
    } else if (t < 190) {
      updates.add(new RunUpdate(l('[0]打开了[英雄联盟]','sklLazySkipTurn4'), p));
    } else if (t < 230) {
      updates.add(new RunUpdate(l('[0]打开了[微博]','sklLazySkipTurn5'), p));
    } else {
      updates.add(new RunUpdate(l('[0]打开了[朋友圈]','sklLazySkipTurn6'), p));
    }

    updates.add(new RunUpdate(l('这回合什么也没做','sklLazySkipTurn0'), p));
  }
}

class SklLazyDefend extends Skill implements PostDamageEntry {
  void addToProcs(){
    owner.postdamages.add(this);
  }

  void postDamage(int dmg, Plr caster, R r, RunUpdates updates) {
    LazyState lazyState = caster.meta[Dt.lazy] as LazyState;
     if (lazyState == null) {
       lazyState = new LazyState(this.owner, caster);
       lazyState.add();
       updates.add(new RunUpdate(l('[1]感染了[懒癌]','sklLazyHit'), owner, caster));
     }
  }
}

class SklLazyAttack extends ActionSkl {

  static void onDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    LazyState lazyState = target.meta[Dt.lazy] as LazyState;
     if (lazyState == null && target is! BossLazy) {
       lazyState = new LazyState(caster, target);
       lazyState.add();
       updates.add(new RunUpdate(l('[1]感染了[懒癌]','sklLazyHit'), caster, target));
     }
  }
  final Plr owner;

  SklLazyAttack(this.owner);

  double atboost = 1.0;
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;
    LazyState lazyState = target.meta[Dt.lazy] as LazyState;
    if (lazyState != null && r.c50) {
      LazyState.beLazy(owner, r, updates);
      atboost += 0.5;
      return;
    }
    double atp = Alg.getAt(owner, false, r) * atboost;

    updates.add(new RunUpdate(l('[0]发起攻击','sklAttack'), owner, target));
    if (target.attacked(atp, false, owner, onDamage, r, updates) > 0) {
      atboost = 1.0;
    }
  }
}
