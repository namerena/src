part of md5;

class BerserkState extends ActionSkl implements PreActionEntry, IMeta {
  int step = 1;

  BerserkState(Plr owner) {
    this.owner = owner;
  }

  Plr get target => owner;

  int get metaType => -1;

  Plr selectOneTarget(R r) {
    return r.pick(owner.group.f.alives);
  }

  double scoreTarget(Plr target, bool smart, R r) {
    return r.rFFFF.toDouble() * target.attract;
  }

  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates) {
    return this;
  }

  void add() {
    target.meta[Dt.berserk] = this;
    target.preactions.add(this);
  }

  void destroy(Plr caster, RunUpdates updates) {
    unlink();
    target.meta.remove(Dt.berserk);
    if (target.alive) {
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdateCancel(
          l('[1]从[狂暴]中解除', 'sklBerserkEnd'), caster, target));
    }
  }

  @override
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    step--;

    Plr target = targets[0].p;
    double atp = Alg.getAt(owner, false, r);
    atp *= 1.2;
    updates.add(
        new RunUpdate(l('[0]发起[狂暴攻击]', 'sklBerserkAttack'), owner, target));
    target.attacked(atp, false, owner, Skill.onDamage, r, updates);

    if (step == 0) {
      destroy(null, updates);
    }
  }
}

class SklBerserk extends ActionSkl {
  bool validTarget(Plr target, bool smart) {
    if (smart) {
      if (target.meta[Dt.berserk] != null) {
        return false;
      }
      return target is! Minion;
    }
    return true;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    double rslt = super.scoreTarget(target, smart, r);
    if (target.meta[Dt.berserk] != null || target.meta[Dt.charm] != null) {
      rslt /= 1.2;
    }
    return rslt;
  }

  static void onDamage(
      Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    if (dmg > 0 && !target.dead) {
      if (target.immune(Dt.berserk, r)) {
        return;
      }

      BerserkState berserkState = target.meta[Dt.berserk] as BerserkState;
      if (berserkState == null) {
        berserkState = new BerserkState(target);
        berserkState.add();
        updates.add(new RunUpdate(
            l('[1]进入[狂暴]状态', 'sklBerserkHit') + Dt.s_berserk,
            caster,
            target,
            null,
            null,
            60));
      } else {
        berserkState.step++;
      }
      if (caster.meta.containsKey(Dt.charge)) {
        berserkState.step++;
      }
    }
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    double atp = Alg.getAt(owner, true, r);
    updates.add(new RunUpdate(
        l('[0]使用[狂暴术]', 'sklBerserk'), owner, target, null, null, 1));
    target.attacked(atp, true, owner, onDamage, r, updates);
  }
}
