part of md5;

class Grp {
  static int compare(Grp g1, Grp g2) {
    return Plr.compare(g1.players[0], g2.players[0]);
  }

  // init from dispPlayer
  void sort() {
    dispPlayers = initPlayers.toList();
    players = initPlayers.toList()..sort(Plr.compare);
    alives = players.toList();
  }

  final Fgt f;

  Grp(this.f);

  String sglName;

  // initial set
  List<Plr> initPlayers = <Plr>[];

  // disp
  List<Plr> dispPlayers = <Plr>[];

  // inited in sort
  List<Plr> players = <Plr>[];

  List<Plr> alives = <Plr>[];

  /// add new plr at runtime
  void addNew(IAddPlr p) {
    /// add to global first, so it's easy to find the last plr in current grp
    f.addNew(p, this);
    
    if (!players.contains(p)) {
      players.add(p);
    }
    if (!dispPlayers.contains(p)) {
      dispPlayers.add(p);
    }
    if (!alives.contains(p)) {
      alives.add(p);
    } 
  }

  void die(Plr p) {
    alives.remove(p);
    f.remove(p);
    if (alives.length == 0) {
      f.checkWin();
    }
  }
  void revive(Plr p) {
    if (!alives.contains(p)) {
      f.revive(p, this);
      alives.add(p);
    } else {
      debug('invalid revive');
    }
   
  }

  String toString() {
    return (initPlayers[0].toString());
  }
}
