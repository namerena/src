part of md5;

class NoWeapon extends Weapon {
  NoWeapon(String name, Plr p) : super._(name, p);

  void init(R r) {
  }

  void preUpgrade() {}

  void upgradeSkill() {}
}
