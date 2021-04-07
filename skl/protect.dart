part of md5;

class ProtectStat extends PreDefendEntry with IMeta {
  final Plr target;
  ProtectStat(this.target);

  // can not be cleard
  int get metaType => 0;

  List<SklProtect> protectFrom = <SklProtect>[];
  SklProtect getProtecter(R r) {
    SklProtect rslt;
    while (protectFrom.isNotEmpty) {
      SklProtect pskl = r.pick(protectFrom);
      if (pskl.owner.allyGroup == target.group && r.r127 < pskl.level && pskl.owner.mpReady(r)) {
        // select next target
        pskl.selectProtectTarget(r);
        return pskl;
      } else {
        // fail to protect, won't protect until next turn
        removeProtect(pskl);
        pskl.protectTo = null;
      }
    }
    return null;
  }

  void removeProtect(SklProtect skl) {
    protectFrom.remove(skl);
    if (protectFrom.isEmpty) {
      unlink();
      target.meta.remove(Dt.protect);
    }
  }

  double preDefend(double atp, bool isMag, Plr caster, Plr target, OnDamage ondmg,
      R r, RunUpdates updates) {
    SklProtect skl = getProtecter(r);
    if (skl != null) {
      Plr p = skl.owner;
      updates.add(new RunUpdate(l('[0][守护][1]','sklProtect'), p, target, null, null, 40));

      atp = p.preDefend(atp, isMag, caster, ondmg, r, updates);
      if (atp == 0.0) {
        return 0.0;
      }
      num dfp = Alg.getDf(p, isMag, r);
      int dmg = (atp * 0.5 / dfp).floor();
      dmg = p.postDefend(dmg, caster, ondmg, r, updates);

      p.damage(dmg, caster, ondmg, r, updates);

      return 0.0;
    }
    return atp;
  }


}

class SklProtect extends Skill implements PostActionEntry {
  Plr selectOneTarget(R r) {
    return owner.selectAlly(r);
  }

  bool validTarget(Plr target, bool smart) {
    return target is! Minion;
  }

  double scoreTarget(Plr target, bool smart, R r) {
    if (smart) {
       int protLen = 1;
       ProtectStat protect = target.meta[Dt.protect] as ProtectStat;
       if (protect != null) {
         protLen = protect.protectFrom.length + 1;
       }
       return Alg.rateLowHp(target) * target.atksum / protLen;
    }
    return r.rFFFF.toDouble();
  }

  bool get allowSneak => false;

  Plr protectTo;

  void selectProtectTarget(R r) {
    List<PlrScore> targets = select(r.r127 < owner.itl, r);
    Plr target;
    if (targets != null) {
      target = targets[0].p;
    }
    if (protectTo == target) {
      return;
    }

    if (protectTo != null) {
      ProtectStat protectStat = protectTo.meta[Dt.protect] as ProtectStat;
      if (protectStat != null) {
        protectStat.removeProtect(this);
      }
    }
    protectTo = target;
    if (target != null) {
      ProtectStat protect = target.meta[Dt.protect] as ProtectStat;
      if (protect == null) {
        protect = new ProtectStat(target);
        target.meta[Dt.protect] = protect;
        target.predefends.add(protect);
      }
      protect.protectFrom.add(this);
    }
  }

  bool postAction(R r, RunUpdates updates) {
    selectProtectTarget(r);
    return false;
  }
  void addToProcs(){
    owner.postactions.add(this);
  }
}
