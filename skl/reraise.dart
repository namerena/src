part of md5;

class SklReraise extends Skill implements DieEntry {
  @override
  double get sortId => 10.0;
  
  bool die(int dmg, Plr caster, R r, RunUpdates updates) {
    if (r.r127 < level ) {
      level = (level+1) ~/ 2;
     
      updates.add(new RunUpdate(l('[0]使用[护身符]抵挡了一次死亡', 'sklReraise') + Dt.s_revive, owner, owner, null, null, 80, 1500));
      owner.hp = r.r16;
      updates.add(new RunUpdate(l('[1]回复体力[2]点','recover'), owner, new HPlr(owner, 0), new HRecover(owner.hp)));
      return true;
    }
    return false;
  }
  void addToProcs(){
    owner.dies.add(this);
  }
}