part of md5;

const RinickModifierHP = 324;

class RinickModifier extends Weapon {

  RinickModifier(String name, Plr p) :super._(name, p);

  void postUpgrade() {
    attrAdd = p.attr.map((n)=>63-n).toList();
    if (p.attr[7] < RinickModifierHP) {
      attrAdd[7] = RinickModifierHP - p.attr[7];
    } else {
      attrAdd[7] = 0;
    }

    super.postUpgrade();
  }

  void upgradeSkill() {

    {
      RinickModifierUpdateState m = new RinickModifierUpdateState();
      p.updatestates.add(m);
    }

    if ( p.idName != Dt.rinick) {
      for (var skil in p.sortedSkills) {
        if (skil.level == 0) {
          skil.level = 4;
          skil.addToProcs();
        } else {
          skil.level <<= 1;
        }
      }
      return;
    }

    for (int i in [0, 2, 15, 18, 27, 28, 32, 37, 38]) {
      var skil = p.sortedSkills[i];
      if (skil.level == 0) {
        skil.level = 8;
        skil.addToProcs();
      } else {
        print(i);
      }
    }

    for (var skil in p.sortedSkills) {
      if (skil is! ActionSkl) {
        if (skil.level == 0) {
          skil.level = 16;
          skil.addToProcs();
        } else {
          skil.level += 16;
        }
      }
    }

    {
      SklAokijiIceAge s = (new SklAokijiIceAge())
        ..init(p, 20);
      p.skills.add(s);
      p.sortedSkills.add(s);
    }
    {
      SklYuriControl s = (new SklYuriControl(p))
        ..init(p, 10);
      p.skills.add(s);
      p.sortedSkills.add(s);
    }
    {
      SklRinickModifierReraise s = new SklRinickModifierReraise(p, 2)
        ..init(p, 8);
      p.skills.add(s);
      p.sortedSkills.add(s);
      s.addToProcs();
    }

    {
      RinickModifierPreAction m = new RinickModifierPreAction(p);
      p.preactions.add(m);
    }

  }
}

class RinickModifierPreAction extends PreActionEntry {
  double get sortId => 0.0;
  Plr owner;

  RinickModifierPreAction(this.owner) {}
  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates) {

    bool findNegState = false;
    owner.meta.forEach((key, IMeta meta){
      if (meta.metaType < 0) {
        findNegState = true;
      }
    });
    if (findNegState) {
      int currentUpdateLen = updates.updates.length;
      owner.clearStates(owner, updates);
      if (updates.updates.length != currentUpdateLen) {
        // if something is cleared
        updates.updates.insert(currentUpdateLen, new RunUpdate(l('[0]使用[属性修改器]', 'weaponRModifierUse'), owner, null, null, null, 60));
        updates.add(RunUpdate.newline);
      }
    }

    int enemyCount = owner.group.f.alives.length - owner.group.alives.length;
    int needAlly = (enemyCount >> 1) - owner.group.alives.length;
    if (needAlly > 0) {
      // super clone
      return new SklRinickModifierClone(needAlly)..init(owner, 0);
    }

    return skl;
  }
}


class RinickModifierUpdateState extends UpdateStateEntry {
  double get sortId => 0.0;

  void updateState(Plr p) {
    if (p.attr[0] < 63) {
      p.attr[0] = 63;
      p.atk = 63;
    }
    if (p.attr[1] < 63) {
      p.attr[1] = 63;
      p.def = 63;
    }
    if (p.attr[2] < 63) {
      p.attr[2] = 63;
      p.spd = 63 + 160;
    }
    if (p.attr[3] < 63) {
      p.attr[3] = 63;
      p.agl = 63;
    }
    if (p.attr[4] < 63) {
      p.attr[4] = 63;
      p.mag = 63;
    }
    if (p.attr[5] < 63) {
      p.attr[5] = 63;
      p.mdf = 63;
    }
    if (p.attr[6] < 63) {
      p.attr[6] = 63;
      p.itl = 63;
    }
  }
}



class SklRinickModifierClone extends ActionSkl {
  int count;
  SklRinickModifierClone(this.count);

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {

    owner.spsum = (r.r255 * 4) + 1024;

    updates.add(new RunUpdate(l('[0]使用[属性修改器]', 'weaponRModifierUse'), owner, null, null, null, 60));

    for (int i = 0; i < count;++i) {
      PlrClone cloned;
      cloned = new PlrClone(owner);
      cloned.group = owner.group;
      cloned.build();
      cloned.spsum = (r.r255 * 4) + 1024;

      owner.group.addNew(cloned);
      updates.add(RunUpdate.newline);
      updates.add(new RunUpdate(
          l('出现一个新的[1]', 'sklCloned'), owner, new HPlr(cloned, cloned.hp)));
    }
  }
}


class SklRinickModifierReraise extends SklMarioReraise {
  SklRinickModifierReraise(Plr mario, int life) : super(mario, life);
  void restore(RunUpdates updates) {
    owner.attr.length = 0;
    owner.initRawAttr();
    owner.initValues();
  }

  void afterReraise(R r, RunUpdates updates) {
    int enemyCount = owner.group.f.alives.length - owner.group.alives.length;
    int needAlly = (enemyCount >> 1) - owner.group.alives.length;
    if (needAlly > 0) {
      updates.add(RunUpdate.newline);
      var skil = new SklRinickModifierClone(needAlly)..init(owner, 1);
      skil.act([], true, r, updates);
    }
  }
}
