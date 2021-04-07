part of md5;

class SklAttack extends ActionSkl {
  static void onNormalDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {}

  SklAttack(Plr owner) {
    this.owner = owner;
  }
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;
    if (smart && owner.mag > owner.atk) {
      int reqmp = (owner.mag - owner.atk) >> 2;
      if (owner.mp >= reqmp) {
        owner.mp -= reqmp;
        double atp = Alg.getAt(owner, true, r);
        updates.add(new RunUpdate(l('[0]发起攻击','sklMagicAttack'), owner, target));
        target.attacked(atp, true, owner, Skill.onDamage, r, updates);
        return;
      }
    }
    double atp = Alg.getAt(owner, false, r);
    updates.add(new RunUpdate(l('[0]发起攻击','sklAttack'), owner, target));
    target.attacked(atp, false, owner, onNormalDamage, r, updates);
  }
}

/// always physical
class SklSimpleAttack extends ActionSkl {
  SklSimpleAttack(Plr owner) {
    this.owner = owner;
  }
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;
    double atp = Alg.getAt(owner, false, r);
    updates.add(new RunUpdate(l('[0]发起攻击','sklAttack'), owner, target));
    target.attacked(atp, false, owner, Skill.onDamage, r, updates);
  }
}
