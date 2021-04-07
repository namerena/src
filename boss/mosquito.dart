part of md5;

// l('蚊','bossName_mosquito')

class BossMosquito extends PlrBoss {
  BossMosquito(String baseName, String clanName)
      : super(baseName, clanName);

  List<int> get appendAttr => const [-3, 24, 29, 729, 5, 7, 12, -35];

  List<String> get immunedx => [Dt.assassinate, Dt.disperse];
  List<String> get immuned => [Dt.berserk,Dt.charm];

  void createSkills() {
    dftAct = new SklSimpleAttack(this);

    skills.add(new SklAbsorb()..level = 100);

  }
}
