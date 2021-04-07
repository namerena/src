part of md5;

class PlrScore {
  static int compare(PlrScore p1, PlrScore p2) {
    return p2.score.compareTo(p1.score);
  }

  Plr p;
  double score;
  PlrScore(this.p, this.score);
}

abstract class Skill extends MEntry implements IProc {
  // when it's done, remove from proc list
  bool procDone = false;

  // when true, means the skill was 0 before boost
  bool boosted = false;

  int level = 0;
  Plr owner;

  void init(Plr owner, int l) {
    this.owner = owner;
    if (l > 0) {
      level = l;
    } else {
      level = 0;
    }
  }
  void addToProcs(){

  }

  Plr selectOneTarget(R r) {
    return owner.selectEnemy(r);
  }

  bool validTarget(Plr target, bool smart) {
    return true;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    return scoreTargetImpl(target, smart, r, false);
  }
  double scoreTargetImpl(Plr target, bool smart, R r, [bool hihp=false]) {
    if (smart) {
      if (owner.group.f.aliveGCount > 2) {
        return Alg.rateHiHp(target) * target.group.alives.length * target.attract;
      } else if (hihp) {
        return Alg.rateHiHp(target) * target.attrsum * target.attract;
      } else {
        return Alg.rateLowHp(target) * target.atksum * target.attract;
      }
    }
    return r.rFFFF.toDouble() +  target.attract;
  }

  int get selCount => 2;
  int get selCountSmart => 3;

  List<PlrScore> select(bool smart, R r) {
    int n = smart ? selCountSmart : selCount;

    List<Plr> plrs = <Plr>[];
    int dup = 0;
    int invalid = -n;
    while (dup <= n && invalid <= n) {
      Plr p = selectOneTarget(r);
      if (p == null) {
        return null;
      }
      bool valid = validTarget(p, smart);

      if (!valid) {
        ++invalid;
        continue;
      }
      if (!plrs.contains(p)) {
        plrs.add(p);
        if (plrs.length >= n) {
          break;
        }
      } else {
        ++dup;
      }
    }
    if (plrs.isEmpty) {
      return null;
    }
    List<PlrScore> rslt = <PlrScore>[];
    for (Plr p in plrs) {
      double score = scoreTarget(p, smart, r);
      rslt.add(new PlrScore(p, score));
    }

    rslt.sort(PlrScore.compare);
    return rslt;
  }
  static void onDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates) {}
}

abstract class ActionSkl extends Skill {
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates);

  bool prob(R r, bool smart) {
    return r.r127 < level;
  }
}
