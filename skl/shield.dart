part of md5;

class ShieldStat extends PostDefendEntry with IMeta {
  double get sortId => 6000.0;

  final Plr target;

  ShieldStat(this.target);

  // positive meta
  int get metaType {
    if (shield > 0) {
      return 1;
    }
    return 0;
  }

  int shield = 0;

  int postDefend(
      int dmg,
      Plr caster,
      ondmg(Plr caster, Plr target, int dmg, R r, RunUpdates updates),
      R r,
      RunUpdates updates) {
    if (shield == 0) {
      return dmg;
    }
    if (dmg > shield) {
      shield = 0;
      dmg -= shield;
    } else {
      shield -= dmg;
      dmg = 0;
    }
    return dmg;
  }

  void destroy(Plr caster, RunUpdates updates) {
    this.unlink();
    target.meta.remove(Dt.shield);
  }
}

class SklShield extends Skill implements PreActionEntry {
  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates) {
    if (level > 0) {
      ShieldStat shieldState = owner.meta[Dt.shield] as ShieldStat;
      if (shieldState == null) {
        shieldState = new ShieldStat(owner);
        owner.meta[Dt.shield] = shieldState;
        owner.postdefends.add(shieldState);
      }
      if (level >= shieldState.shield) {
        shieldState.shield += r.nextInt(1 + level * 3 ~/ 4) + 1;
      }
    }
    return skl;
  }

  void addToProcs() {
    owner.preactions.add(this);
  }
}
