part of md5;

/// only purpose for this is to keep an id on each unique clone
class MinionCount extends IMeta {
  final Plr target;
  MinionCount(this.target);
  // neutral meta
  int get metaType => 0;

  int count = 0;

  static String getMinionName(Plr p) {
    while (p is IAddPlr) {
      p = (p as IAddPlr).owner;
    }
    MinionCount cloneState = p.meta[Dt.minionCount] as MinionCount;
    if (cloneState == null) {
      cloneState = new MinionCount(p);
      p.meta[Dt.minionCount] = cloneState;
    }
    return '${p.baseName}?${cloneState.count++}@${p.clanName}';
  }
}

class PlrClone extends Plr implements IAddPlr {
  Plr original;
  Plr from;
  Plr get owner {
    return original;
  }

  PlrClone(Plr from) : super(from.baseName, from.clanName, from.sglName, from.weaponName) {
    this.from = from;
    if (from is PlrClone) {
      original = from.original;
    } else {
      original = from;
    }

    idName = MinionCount.getMinionName(original);
    ss = from.ss.toList();
  }

  @override
  void addSkillsToProc() {
    if (skills.length == from.skills.length) {
      for (int i = 0; i < skills.length; ++i) {
        if (skills[i].level > from.skills[i].level) {
          skills[i].level = from.skills[i].level;
        }
      }
    }

    super.addSkillsToProc();
  }

  void initRawAttr() {
    attr = from.attr.toList();
    calcAttrSum();
  }
}

class SklClone extends ActionSkl {
  SklClone();

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    PlrClone cloned;

    level = (level * 0.75).ceil();
    if (!owner.meta.containsKey(Dt.charge)) {
      List attr = owner.attr;

      for (int i = 0; i < 6; ++i) {
        attr[i] = (attr[i] * 0.6).ceil(); //0.58
      }

      attr[7] = (attr[7] * 0.5).ceil();

      owner.hp = (owner.hp * 0.5).ceil();
      owner.calcAttrSum();
      owner.updateStates();
    }

    owner.spsum = (r.r255 * 4) + 1024;

    cloned = new PlrClone(owner);
    cloned.group = owner.group;
    cloned.build();
    cloned.spsum = (r.r255 * 4) + 600;
    cloned.hp = owner.hp;

    if (owner.hp + owner.mag < r.r255) {
      level = (level >> 1) + 1;
    }
    cloned.skills.firstWhere((skill) => skill is SklClone)?.level = level;

    updates
        .add(new RunUpdate(l('[0]使用[分身]', 'sklClone'), new MPlr(owner), owner, null, null, 60));

    owner.group.addNew(cloned);
    updates.add(new RunUpdate(
        l('出现一个新的[1]', 'sklCloned'), owner, new HPlr(cloned, cloned.hp)));
  }
}
