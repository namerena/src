part of md5;

class SklAbsorb extends ActionSkl {

  bool prob(R r, bool smart) {
    if (smart) {
      if (owner.maxhp - owner.hp < 32) {
        return false;
      }
    }
    return super.prob(r, smart);
  }

  static void onDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {
    if (dmg > 0 && !caster.dead) {
      int hpr = (dmg + 1) ~/ 2;
      if (hpr > caster.maxhp - caster.hp) {
        hpr = caster.maxhp - caster.hp;
      }
      int oldhp = caster.hp;
      caster.hp += hpr;
      updates.add(
          new RunUpdate(l('[1]回复体力[2]点','recover'), caster, new HPlr(caster, oldhp), new HRecover(hpr), null, hpr));
    }
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = targets[0].p;

    double atp = Alg.getAt(owner, true, r) * 1.3;
    updates.add(new RunUpdate(l('[0]发起[吸血攻击]', 'sklAbsorb'), owner, target, null, null, 1));
    target.attacked(atp, true, owner, onDamage, r, updates);
  }
}
