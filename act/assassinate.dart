part of md5;

class SklAssassinate extends ActionSkl implements PreActionProc, PostDamageProc{

  PreActionImpl onPreAction;
  PostDamageImpl onPostDamge;
  SklAssassinate(){
    onPreAction = new PreActionImpl(this);
    onPostDamge = new PostDamageImpl(this);
  }

  bool prob(R r, bool smart) {
    if (smart && (owner.meta.containsKey(Dt.poison))) {
      return false;
    }
    return super.prob(r, smart);
  }

  bool validTarget(Plr target, bool smart) {
    if (smart) {
      return target.hp > 160;
    }
    return true;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    return scoreTargetImpl(target, smart, r, true);
  }

  @override
  List<PlrScore> select(bool smart, R r) {
    if (target != null) {
      return [];
    }
    return super.select(smart, r);
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    if (target == null) {
      // first round
       target = targets[0].p;
       updates.add(new RunUpdate(l('[0][潜行]到[1]身后', 'sklAssassinate1'), owner, target, null, null, 1));
       owner.preactions.add(onPreAction);
       owner.spsum += owner.mag*3;
       if (owner.meta.containsKey(Dt.charge)) {
         owner.spsum += 1600;
       } else {
         owner.postdamages.add(onPostDamge);
       }
    } else {
      // second round
      Plr saveTarget = target;
      clear();
      if (saveTarget.alive) {
        updates.add(new RunUpdate(l('[0]发动[背刺]','sklAssassinate2'), owner, saveTarget, null, null, 1));

        double atp = Alg.getAt(owner, true, r);
        double atp2 = Alg.getAt(owner, true, r);
        if (atp2 > atp){
          atp = atp2;
        }
        atp2 = Alg.getAt(owner, true, r);
        if (atp2 > atp){
          atp = atp2;
        }
        if (saveTarget.immune(Dt.assassinate, r)) {
          updates.add(new RunUpdate(l('[0][回避]了攻击','dodge'), saveTarget , owner));
          return;
        } else {
          atp *= 4.0;
        }

        saveTarget.defend(atp, true, owner, Skill.onDamage, r, updates);
      }
    }
  }

  Plr target;


  @override
  void postDamage(int dmg, Plr caster, R r, RunUpdates updates) {
    updates.add(RunUpdate.newline);
    updates.add(new RunUpdateCancel(l('[0]的[潜行]被识破', 'sklAssassinateFailed'), owner, target));
    clear();
  }

  @override
  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates) {
    if (target != null && target.alive) {
      return this;
    } else {
      clear();
    }
    return null;
  }

  void clear() {
    target = null;
    onPostDamge.unlink();
    onPreAction.unlink();
  }
}
