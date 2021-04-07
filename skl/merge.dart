part of md5;

class MergeState extends IMeta {
  final Plr target;
  MergeState(this.target);
  int get metaType => 0;
}

class SklMerge extends Skill implements KillEntry {

  void addToProcs() {
    owner.kills.add(this);
  }

  bool kill(Plr target, R r, RunUpdates updates) {
    if (r.r63 < level) {

      bool merged = false;
      for (int i = 0; i < owner.attr.length; ++i) {
        if (target.attr[i] > owner.attr[i]) {
          owner.attr[i] = target.attr[i];
          merged = true;
        }
      }
      for (int i = 0;
          i < owner.skills.length && i < target.skills.length;
          ++i) {
        Skill s1 = owner.skills[i];
        Skill s2 = target.skills[i];
        if (s1.runtimeType != s1.runtimeType) {
          break;
        }
        if (s2.level > s1.level) {
          if (s1.level == 0) {
            s1.level = s2.level;
            if (s1 is ActionSkl) {
              owner.actions.add(s1);
            }
            s1.addToProcs();
          } else {
            s1.level = s2.level;
          }
          merged = true;
        }
      }
      if (target.mp > owner.mp) {
        owner.mp = target.mp;
        target.mp = 0;
      }
      if (target.spsum > owner.spsum) {
        owner.spsum += target.spsum;
        target.spsum = 0;
      }
      if (merged) {
        target.meta[Dt.corpose] = new MergeState(target);
        owner.updateStates();
        updates.add(RunUpdate.newline);
        updates.add(new RunUpdate(
            l('[0][吞噬]了[1]', 'sklMerge'), owner, target, null, null, 60,  1500));
        updates.add(new RunUpdate(
                 l('[0]属性上升', 'sklMerged'), new MPlr(owner), target));
        return true;
      }

    }
    return false;
  }
}
