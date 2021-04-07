part of md5;


class PlrZombie extends Minion {
  SklZombie skl;
  Plr get owner {
    return skl.owner;
  }
  PlrZombie(SklZombie s) : super('${s.owner.baseName}?${Dt.zombie}', s.owner.clanName, s.owner.sglName) {
    skl = s;
    idName = MinionCount.getMinionName(skl.owner);
  }

  void createSkills() {
    dftAct = new SklAttack(this);
    // no other skills
  }
  void initRawAttr() {
    super.initRawAttr();
    attr[0] = 0;
    attr[6] = 0;
    attr[7] ~/= 2;
  }

}

class ZombieState extends IMeta {
  final Plr target;
  ZombieState(this.target);
  int get metaType => 0;
}

class SklZombie extends Skill implements KillEntry {

  void addToProcs() {
    owner.kills.add(this);
  }

  bool kill(Plr target, R r, RunUpdates updates) {
    if (target is! Minion && r.r63 < level && owner.mpReady(r)) {
      target.meta[Dt.corpose] = new ZombieState(target);

      PlrZombie zombie = new PlrZombie(this);
      zombie.dispName = l('丧尸','sklZombieName');
      zombie.group = owner.group;
      owner.dies.add(zombie.onOwnerDie);
      zombie.build();
      zombie.spsum = r.r255 * 4
;

      owner.group.addNew(zombie);
      updates.add(RunUpdate.newline);

      updates.add(new RunUpdate(l('[0][召唤亡灵]','sklZombie'), owner, target, null, null, 60, 1500));

      updates.add(new RunUpdate(l('[2]变成了[1]','sklZombied'), owner, new HPlr(zombie, zombie.hp), target, [target]));

      return true;
    }
    return false;
  }
}
