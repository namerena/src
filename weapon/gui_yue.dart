part of md5;

class DummyChargeMeta implements IMeta {
  // not treated as negative, can't be healed
  int get metaType => 0;

  Plr target;

  DummyChargeMeta(this.target);

  void destroy(Plr caster, RunUpdates updates) {}
}

class GuiYue extends Weapon {
  static List<String> members = [
    Dt.rinick,
    Dt.kuzan,
    Dt.kuzan1,
    Dt.hanxu,
    Dt.lingyun,
    Dt.yunjian,
    Dt.xinjiyuan,
    Dt.qilala,
    Dt.chuncai,
    Dt.xueche,
    Dt.phy
  ];

  GuiYue(String name, Plr p) : super._(name, p);

  void init(R r) {}

  void preUpgrade() {}

  void upgradeSkill() {
    this.p.meta[Dt.charge] = new DummyChargeMeta(this.p);
  }
}
