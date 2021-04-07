part of md5;

abstract class IPlr{
  String idName;

  String toString(){
    return idName;
  }
}

class NPlr extends IPlr{
  NPlr(IPlr p) {
    idName = p.idName;
  }
}

/// hp update
class HPlr extends IPlr{
  String pcss;
  int oldHp;
  int newHp;
  HPlr(Plr p, this.oldHp) {
    idName = p.idName;
    newHp = p.hp;
  }
}

/// max hp update
class MPlr extends IPlr{
  int newHp;
  int maxHp;
  MPlr(Plr p) {
    idName = p.idName;
    newHp = p.hp;
    maxHp = p.maxhp;
  }
}


class DPlr extends IPlr{
  DPlr(Plr p) {
    idName = p.idName;
  }
}

class HDamage {
  int damage;
  HDamage(this.damage);
  String toString(){
    return damage.toString();
  }
}
class HRecover {
  int recover;
  HRecover(this.recover);
  String toString(){
    return recover.toString();
  }
}

class RunUpdate {
  static RunUpdate newline = new RunUpdate('\n', null);

  int score;
  int delay0;
  int delay1;
  String message;


  /// caster mostly the skill caster
  /// except during dodge and defend, target is the one that use defend or dodge
  IPlr caster;
  IPlr target;
  List<IPlr> targets2;
  Object param;
  RunUpdate(this.message, this.caster,
      [this.target, this.param, this.targets2, this.score = 0, this.delay0 = 1000, this.delay1 = 100]) {
    if (caster is Plr) {
      caster = new NPlr(caster);
    }
    if (target is Plr) {
      target = new NPlr(target);
    }
    if (param is Plr) {
      param = new NPlr(param as Plr);
      }
    if (targets2 != null) {
      for (int i = 0; i < targets2.length; ++i) {
        if (targets2[i] is Plr) {
          targets2[i] = new NPlr(targets2[i]);
        }
      }
    }
  }

  String toString() {
    String msg = message;
    if (caster != null) {
      msg = msg.replaceAll('[0]', caster.toString());
    }
    if (target != null) {
      msg = msg.replaceAll('[1]', target.toString());
    }
    if (param != null) {
      msg = msg.replaceAll('[2]', param.toString());
    }
    return msg;
  }
}

class RunUpdateCancel extends RunUpdate {
  RunUpdateCancel(String message, IPlr caster,
      [IPlr target, Object param, List<IPlr> targets2, int score = 0, int delay0 = 1000, int delay1 = 500]) :
    super(message, caster, target, param, targets2, score, delay0, delay1);

}

class RunUpdateWin extends RunUpdate {
  Grp get winner => param as Grp;
  RunUpdateWin(IPlr caster, Grp w):super(l('[2]获得胜利', 'win'), caster, null, w, null, 0, 3000);
}

class RunUpdates {
  static DummyRunUpdates dummy = new DummyRunUpdates();

  List<RunUpdate> updates = [];
  void add(RunUpdate update) {
    updates.add(update);
  }

  String toString() {
    return '$updates';
  }
  List<Function> onUpdateEnd = [];
}

class DummyRunUpdates extends RunUpdates {
  void add(RunUpdate update) {
    // do nothing;
  }
}
