part of md5;

class SklDefend extends Skill implements PostDefendEntry {
  double get sortId => 2000.0;
  int postDefend(int dmg, Plr caster, ondmg(Plr caster, Plr target, int dmg, R r, RunUpdates updates), R r, RunUpdates updates) {
    if (r.r255 < level && owner.mpReady(r)) {
      updates.add(new RunUpdate(l('[0][防御]','defend'), owner, caster, null, null, 40));
      return dmg ~/ 2;
    }
    return dmg;
  }
  void addToProcs(){
    owner.postdefends.add(this);
  }
  
}