part of md5;



class PlrBoss extends Plr {
  PlrBoss(String baseName, String clanName) : super(baseName, clanName, '$baseName${Dt.atex}') {
    String s = L(h_('${Dt.bossName}$baseName'));
    if (s != null) {
      dispName = L(h_('${Dt.bossName}$baseName'));
    }
  }

  List<int> get appendAttr => null;
  void initRawAttr(){
    super.initRawAttr();
    if (appendAttr != null) {
      for (int i = 0; i < attr.length; ++i) {
        attr[i] += appendAttr[i];
      }
    }
  }
  void initSkills(List<int> list, List<int> origin) {
    for (int i = 0; i < skills.length; ++i) {
      Skill skl = skills[i];
      skl.init(this, skl.level);
    }
  }
  void addSkillsToProc(){
    for (int i = 0; i < skills.length; ++i) {
      Skill skl = skills[i];
      if (skl is ActionSkl) {
        actions.add(skl);
      }
    }
    for (int i = 0; i < skills.length; ++i) {
      Skill skl = skills[i];
      skl.addToProcs();
    }
  }
  String getScoreStr(){
    return Dt.qq;
  }

  List get immunedx => [];
  List<String> get immuned => [Dt.assassinate, Dt.charm, Dt.berserk, Dt.half, Dt.curse,  Dt.exchange, Dt.slow, Dt.ice];
  bool immune(String key, R r) {
    if (immunedx.contains(key)) {
      return r.c94;
    }
    if (immuned.contains(key)) {
      return r.c75;
    }
    return r.c33;
  }

  static Map<String, int> boosted = {
    b('田一人'):18,
    b('云剑狄卡敢'):25,
    b('云剑穸跄祇'):35
  };

  static Plr chooseBoss(String name, String clanName, Fgt fgt, String weaponName) {
    if (clanName == Dt.u02) {
      return new PlrTest(name, clanName, fgt);
    }
    if (clanName == Dt.u03) {
      return new PlrTest2(name, clanName);
    }
    if (clanName == Dt.ex) {
      if (name == Dt.mario) {
        return new BossMario(name, Dt.ex);
      }
      if (name == Dt.sonic) {
        return new BossSonic(name, Dt.ex);
      }
      if (name == Dt.mosquito) {
        return new BossMosquito(name, Dt.ex);
      }
      if (name == Dt.yuri) {
        return new BossYuri(name, Dt.ex);
      }
      if (name == Dt.slime) {
        return new BossSlime(name, Dt.ex);
      }
      if (name == Dt.ikaruga) {
         return new BossIkaruga(name, Dt.ex);
       }
      if (name == Dt.conan) {
       return new BossConan(name, Dt.ex);
      }
      if (name == Dt.aokiji) {
       return new BossAokiji(name, Dt.ex);
      }
      if (name == Dt.lazy) {
       return new BossLazy(name, Dt.ex);
      }
      if (name == Dt.covid) {
        return new BossCovid(name, Dt.ex);
      }
      if (name == Dt.saitama) {
        return new BossSaitama(name, Dt.ex);
      }
      if (name.startsWith(Dt.seed)) {
        return new PlrSeed(name);
      }
      if (boosted.containsKey(name)) {
        return new PlrBoost(name, Dt.ex, boosted[name], weaponName);
      }
      return new PlrEx(name, Dt.ex, name, weaponName);
    }
    return new Plr(name, clanName, null, weaponName);
  }

}

