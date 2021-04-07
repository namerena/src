part of md5;

abstract class Engine {
  void start(int token);
  String get error;
  Future<RunUpdates> nextUpdates();
}

class Fgt implements Engine{
  // ! ? " [ ]
  static final RegExp invalidNameReg =
      new RegExp(r'[\u0000-\u001F\u2000-\u202F"\?]');
  static final RegExp replaceSpace0 = new RegExp(r'^\s+[:@]*\s*');
  static final RegExp replaceSpace1 = new RegExp(r'\s+$');
  static final RegExp regNewLine = new RegExp(r'\r?\n');

  static bool invalidName(String name) {
    if (name == '' || name.contains(invalidNameReg)) {
      return true;
    }
    if (name.length > 64) {
      return true;
    }
    return false;
  }

  static String fixName(String name) {
    return name
        .replaceFirst(replaceSpace0, ' ')
        .replaceFirst(replaceSpace1, '');
  }

  List<Grp> dispGroups = <Grp>[];

  R r;

  /// running order
  List<Plr> players = <Plr>[];
  List<Grp> groups = <Grp>[];
  List<Plr> alives = <Plr>[];

  String error;
  Map<String, Plr> name2p = new Map<String, Plr>();

  static List<List<List<String>>> parseString(String str) {
    List<List<List<String>>> rslt = [];
     List<String> names = str.split(regNewLine);
     for (int i = 0; i < names.length; ++i) {
       names[i] = fixName(names[i]);
     }
     while (names.last == '') {
       names.removeLast();
       if (names.isEmpty) {
         return [];
       }
     }
     bool grouped = false;
     if (names.contains('')) {
       grouped = true;
     }
     String clanName;
    List<List<String>> currentGroup = [];
     for (int i = 0; i < names.length; ++i) {
       String name = names[i];
       if (name == '') {
         if (currentGroup.isNotEmpty) {
           rslt.add(currentGroup);
         }
         clanName = null;
         currentGroup = [];
         continue;
       }
       if (!grouped) {
         if (currentGroup.isNotEmpty) {
           rslt.add(currentGroup);
         }
         currentGroup = [];
       }
       String weapon = null;
       if (name.contains(Dt.add)) {
         int pos = name.indexOf(Dt.add);
         weapon = name.substring(pos + 1).trim();
         name = name.substring(0, pos).replaceFirst(replaceSpace1, '');
       }
       if (name.contains(Dt.at) ) {
         List<String> nn = name.split(Dt.at);
         if (nn[0].startsWith(' ')) {
           nn[0] = nn[0].substring(1);
         }
         if (nn[1] == '' || nn[1].contains(Dt.cln)) {
           currentGroup.add(<String>[nn[0], null, weapon]);
         } else {
           currentGroup.add(<String>[nn[0], nn[1], weapon]);
         }
       } else if (name.startsWith(' ')) {
         String baseName = name.substring(1);
         currentGroup.add(<String>[baseName, clanName, weapon]);
       } else {
         if (i + 1 < names.length && !name.contains(Dt.cln)
             && names[i + 1].startsWith(' ')) {
           clanName = name;
         } else {
           clanName = null;
           currentGroup.add(<String>[name, null, weapon]);
         }
       }
     }
     if (currentGroup.isNotEmpty) {
       rslt.add(currentGroup);
     }
     return rslt;
  }
  static Future<Fgt> parse(String str) async {

    Fgt f = new Fgt(parseString(str));
    await f._();
    return f;
  }

  List<List> rawGroups;
  Fgt(this.rawGroups);
  bool _ed = false;

  static Future<Fgt> make(List<List> raw) async {
    Fgt f = new Fgt(raw);
    await f._();
    return f;
  }

  List<NonePlr> noPlrs = new List<NonePlr>();
  _() async {
    List<String> seedNames = [];
    for (List glist in rawGroups) {
      Grp group = new Grp(this);
      for (Object obj in glist) {
        if (obj is Plr) {} else if (obj is List<String> && obj.length >= 2) {
          String baseName = obj[0];
          String clanName = obj[1];
          String weaponName = null;
          if (obj.length > 2) {
            weaponName = obj[2];
          }
          Plr p;
          if (obj[1] is String && obj[1].length == 1 && obj[1].codeUnitAt(0) < 34) {
            p = PlrBoss.chooseBoss(obj[0], obj[1], this, weaponName);
          } else {
            p = new Plr(obj[0], obj[1], group.sglName, weaponName);
          }
          if (p is NonePlr) {
            if (p is PlrSeed) {
              seedNames.add(p.idName);
            }
            noPlrs.add(p);
            continue;
          }
          if (name2p.containsKey(p.idName)) {
            continue;
          }
          if (group.sglName == null) {
            group.sglName = p.sglName;
          }
          p.group = group;
          group.initPlayers.add(p);
          name2p[p.idName] = p;
        }
      }
      if (group.initPlayers.isNotEmpty) {
        dispGroups.add(group);
        int len = group.initPlayers.length;
        for (int i = 0; i < len; ++i) {
          Plr p = group.initPlayers[i];
          for (int j = i+1; j< len; ++j) {
            Plr q = group.initPlayers[j];
            if (p.clanName == q.clanName) {
              p.upgrade(q.ss0);
              q.upgrade(p.ss0);
            }
          }
        }
      }
    }
    aliveGCount = dispGroups.length;
    if ((name2p.length >> 10) > 0) {
      error = l('错误，目前最多支持1000人PK', 'errorMaxPlayer');
      return;
    }
    if (name2p.length < 2) {
      error = l('错误，请至少输入两行名字', 'errorMinPlayer');
      return;
    }

    List<String> sortedNames = name2p.keys.toList();
    sortedNames.sort();

    List<String> sortedHashNames;
    if (seedNames.isNotEmpty) {
      sortedHashNames = sortedNames.toList();
      sortedHashNames.addAll(seedNames);
      sortedHashNames.sort();
    } else {
      sortedHashNames = sortedNames;
    }

    List<int> sortedHash = utf8.encode(sortedHashNames.join('\n'));
    r = new R(sortedHash, 1);
    r.encryptBytes(sortedHash);

    for (String name in sortedNames) {
      await
      name2p[name].buildAsync();
      name2p[name].sortInt = r.rFFFFFF;
    }
    for (Grp group in dispGroups) {
      group.sort();
    }
    players = name2p.values.toList()..sort(Plr.compare);

    groups = dispGroups.toList()..sort(Grp.compare);
    for (Grp g in groups) {
      for (Plr p in g.alives) {
        r.encryptBytes(utf8.encode(p.idName));
      }
      r.encryptBytes([0]);
      alives.addAll(g.alives);
    }

    for (Plr p in players) {
      p.spsum = r.r255;
    }
    _ed = true;
  }

  _checktime() async {
    await new Future.delayed(new Duration(milliseconds: 4));
  }
  void remove(Plr p) {
    alives.remove(p);
    if (roundPos <= players.indexOf(p)) {
      roundPos--;
    }
    players.remove(p);
  }

  void addNew(IAddPlr p, Grp g) {
    if (!players.contains(p)) {
      players.add(p);
    }
    if (!alives.contains(p)) {
      if (g.alives.length > 0) {
        int pos = alives.indexOf(g.alives.last);
        alives.insert(pos + 1, p);
      } else {
        alives.add(p);
      }
      if (token > -1) {
        newPlayer(p, g);
      }
    } else {
      debug('invalid add');
    }
  }

  void revive(Plr p, Grp g) {
    if (!players.contains(p)) {
       players.add(p);
    }
    if (!alives.contains(p)) {
      if (g.alives.length > 0) {
        int pos = alives.indexOf(g.alives.last);
        alives.insert(pos + 1, p);
      } else {
        alives.add(p);
      }
    } else {
      debug('invalid revive');
    }
  }
  int aliveGCount = 0;
  void checkWin() {
    aliveGCount --;
    if (alives[0].group.alives.length == alives.length) {
      _winner = alives[0].group;
      throw alives[0].group;
    }
  }

  int roundPos = -1;
  void round(RunUpdates updates) {
    roundPos = (roundPos + 1) % players.length;
    players[roundPos].step(r, updates);
    while (updates.onUpdateEnd.isNotEmpty) {
      List<Function> copy = updates.onUpdateEnd;
      updates.onUpdateEnd = [];
      for (Function fun in copy) {
        fun(r, updates);
      }
    }
  }
  bool _end = false;
  Grp _winner;
  nextUpdates() async{
    if (_end) {
      return null;
    }
    RunUpdates updates = new RunUpdates();
    if (_winner != null) {
      Grp outputwin;
      updates.add(new RunUpdateWin(_winner.initPlayers[0], outputwin));
      _end = true;

      await _checktime();
      return updates;
    }
    try {
      while (_winner == null) {
        round(updates);
        if (updates.updates.isNotEmpty) {
          return updates;
        }
      }
    } catch (err, stack) {
      if (err is Grp) {

      } else {
        debug(err);
        debug(stack);
      }
    }

    if (updates.updates.isNotEmpty) {
      return updates;
    }
    return null;
  }

  int token = -1;
  Float64List float64 = new Float64List(1);
  start(int tt) async {
    token = tt;

    double ts = new DateTime.now().millisecondsSinceEpoch.toDouble() + 2048;

    float64[0] = ts;

    String plrgroups = dispGroups.map((g) {
      return g.dispPlayers.map((p) {
        return p.toDetail();
      }).join('\r');
    }).join('\n');
    if (noPlrs.isNotEmpty) {
      for (NonePlr p in noPlrs) {
        plrgroups += '\n${p.idName}\t${p.toMessage()}';
      }
    }
    String out = Base2e15.encode(utf8
        .encode(plrgroups)
        .reversed
        .map((int b) => b ^ token)
        .toList()..addAll(float64.buffer.asUint8List(0)));
    tunnelWrite(out);
  }
  newPlayer(IAddPlr p, Grp g) async{
    String out = Base2e15.encode(utf8
        .encode('${p.owner.idName}\r${p.toDetail()}')
        .reversed
        .map((int b) => b ^ token)
        .toList()..addAll(float64.buffer.asUint8List(0)));
    tunnelWrite(out);
  }
}
