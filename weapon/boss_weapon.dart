part of md5;

class BossWeapon extends Weapon {
  BossWeapon(String name, Plr p) :super._(name, p) {
    baseName = name.substring(0, name.length - 1);
  }

  void init(R r) {
    r.round(R.utf(p.idName), 2);
    super.init(r);
  }

  int upgrade3Number(List<int> base, List<int> current, List<int> up, int from) {
    int d0 = (up[from] - base[from]);
    int d1 = (up[from + 1] - base[from + 1]);
    int d2 = (up[from + 2] - base[from + 2]);
    for (int pos = 0; pos < 3; ++pos) {
      int dd = (up[from + pos] - current[from + pos]);
      if (dd > 0) {
        current[from + pos] += dd;
      } else if (current[from + pos] < 32) {
        current[from + pos] += 32;
      }
    }
    return d0.abs() + d1.abs() + d2.abs();
  }

  void preUpgrade() {
    upgrade3Number(p.ss0, p.ss, ss, 7);
    super.preUpgrade();
  }
}
