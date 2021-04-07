part of md5;

typedef OnDamage(Plr caster, Plr target, int dmg, R r, RunUpdates updates);

abstract class IMeta {
  Plr get target;
  /// negative for bad state, positive for good state
  int get metaType;

  void destroy(Plr caster, RunUpdates updates){}
}

abstract class IProc {}

abstract class UpdateStateProc extends IProc {
  void updateState(Plr p);
}

abstract class PreStepProc extends IProc {
  int preStep(int step, R r, RunUpdates updates);
}

abstract class PreDefendProc extends IProc {
  double preDefend(double atp, bool isMag, Plr caster, Plr target, OnDamage ondmg,
      R r, RunUpdates updates);
}

abstract class PostDefendProc extends IProc {
  int postDefend(int dmg, Plr caster, OnDamage ondmg, R r, RunUpdates updates);
}

abstract class PostDamageProc extends IProc {
  void postDamage(int dmg, Plr caster,R r, RunUpdates updates);
}

abstract class PreActionProc extends IProc {
  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates);
}

abstract class PostActionProc extends IProc {
  void postAction(R r, RunUpdates updates);
}

abstract class DieProc extends IProc {
  bool die(int dmg, Plr caster, R r, RunUpdates updates);
}

abstract class KillProc extends IProc {
  /// return true when the body is consumed
  bool kill(Plr target, R r, RunUpdates updates);
}

abstract class UpdateStateEntry extends MEntry implements UpdateStateProc {}

abstract class PreStepEntry extends MEntry implements PreStepProc {}

abstract class PreDefendEntry extends MEntry implements PreDefendProc {}

abstract class PostDefendEntry extends MEntry implements PostDefendProc {}

abstract class PostDamageEntry extends MEntry implements PostDamageProc {}

abstract class PreActionEntry extends MEntry implements PreActionProc {}

abstract class PostActionEntry extends MEntry implements PostActionProc {}

abstract class DieEntry extends MEntry implements DieProc {}

abstract class KillEntry extends MEntry implements KillProc {}

class UpdateStateImpl extends UpdateStateEntry {
  double sortId = double.infinity;
  UpdateStateProc _proc;
  UpdateStateImpl(this._proc);

  void updateState(Plr p) {
    _proc.updateState(p);
  }
}

class PreStepImpl extends PreStepEntry {
  double sortId = double.infinity;
  PreStepProc _proc;
  PreStepImpl(this._proc);

  int preStep(int step, R r, RunUpdates updates) {
    return _proc.preStep(step, r, updates);
  }
}

class PreDefendImpl extends PreDefendEntry {
  double sortId = double.infinity;
  PreDefendProc _proc;
  PreDefendImpl(this._proc);
  double preDefend(double atp, bool isMag, Plr caster, Plr target, OnDamage ondmg,
      R r, RunUpdates updates) {
    return _proc.preDefend(atp, isMag, caster, target, ondmg, r, updates);
  }
}

class PostDefendImpl extends PostDefendEntry {
  double sortId = double.infinity;
  PostDefendProc _proc;
  PostDefendImpl(this._proc);
  int postDefend(int dmg, Plr caster, OnDamage ondmg, R r, RunUpdates updates) {
    return _proc.postDefend(dmg, caster, ondmg, r, updates);
  }
}

class PostDamageImpl extends PostDamageEntry {
  double sortId = double.infinity;
  PostDamageProc _proc;
  PostDamageImpl(this._proc);
  void postDamage(int dmg, Plr caster, R r, RunUpdates updates) {
    return _proc.postDamage(dmg, caster, r, updates);
  }
}

class PreActionImpl extends PreActionEntry {
  double sortId = double.infinity;
  PreActionProc _proc;
  PreActionImpl(this._proc);
  ActionSkl preAction(ActionSkl skl, bool smart, R r, RunUpdates updates) {
    return _proc.preAction(skl, smart, r, updates);
  }
}

class PostActionImpl extends PostActionEntry {
  double sortId = double.infinity;
  PostActionProc _proc;
  PostActionImpl(this._proc);
  void postAction(R r, RunUpdates updates) {
    return _proc.postAction(r, updates);
  }
}

class DieImpl extends DieEntry {
  double sortId = double.infinity;
  DieProc _proc;
  DieImpl(this._proc);
  bool die(int dmg, Plr caster, R r, RunUpdates updates) {
    return _proc.die(dmg, caster, r, updates);
  }
}

class KillImpl extends KillEntry {
  double sortId = double.infinity;
  KillProc _proc;
  KillImpl(this._proc);
  bool kill(Plr target, R r, RunUpdates updates) {
    return _proc.kill(target, r, updates);
  }
}
