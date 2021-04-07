part of md5;

class SklVoid extends ActionSkl {
  static SklVoid instance = new SklVoid();
  
  void init(Plr owner, int l) {
    this.owner = owner;
    level = 0;
  }
  
  bool prob(R r, bool smart) {
    return false;
  }
  List<PlrScore> select(bool smart, R r) {
    return null;
  }
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    return;
  }
}