part of md5;


class SklDeathNote extends ActionSkl implements PostDamageProc {
  PostDamageImpl onPostDamage;

  Plr notes;

  SklDeathNote() {
    boosted = true;
    onPostDamage = new PostDamageImpl(this);
  }

  bool prob(R r, bool smart) {
    if (notes != null && notes.alive) {
      if (smart) {
        return notes.group != owner.group;
      } else {
        return r.c50;
      }
    }
    return false;
  }

  void addToProcs() {
    owner.postdamages.add(onPostDamage);
  }

  List<PlrScore> select(bool smart, R r) {
    return [];
  }

  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    Plr target = notes;
    updates.add(
        new RunUpdate(
            l('[0]在[死亡笔记]写下[1]的名字', 'weaponDeathNoteAtk'), owner, notes, null,
            null, 20));
    notes.damage(notes.hp, owner, Skill.onDamage, r, updates);
    owner.spd -= 1024;
    if (owner.mp > 0) {
      owner.mp = 0;
    }
    notes = null;
  }

  void postDamage(int dmg, Plr caster, R r, RunUpdates updates) {
    if (dmg > 0 && caster != owner &&
        Alg.dodge(caster.itl + caster.mdf, owner.itl + owner.mag, r)) {
      notes = caster;
    }
  }
}

class WeaponDeathNote extends Weapon {
  WeaponDeathNote(String name, Plr p) :super._(name, p);

//  void init(R r) {
//    super.init(r);
//    attrAdd = [11, 0, 11, 0, 0, 0, 0, 0];
//  }

  void upgradeSkill() {
    SklDeathNote s = (new SklDeathNote())
      ..init(p, 1);
    p.skills.add(s);
    p.sortedSkills.add(s);
  }
}
