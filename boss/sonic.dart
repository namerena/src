part of md5;

// l('索尼克','bossName_sonic')

class BossSonic extends PlrBoss {
  BossSonic(String baseName, String clanName)
      : super(baseName, clanName);

  List<int> get appendAttr => const  [10, -6, 1000, 0, 10, -15, 6, 0];

  List<String> get immunedx => [];
  List<String> get immuned => [Dt.poison];

  void createSkills() {
    dftAct = new SklSimpleAttack(this);

    skills.add(new SklRapid()..level = 48);
    skills.add(new SklCritical()..level = 48);
    skills.add(new SklCounter()..level = 48);
  }
}
