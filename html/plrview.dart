part of md5.html;



class PlrGroup {
  DivElement divlist = Div('plrg_list');
  DivElement divbody;
  PlrGroup(List<List<String>> input, bool grouped, bool detailed) {
    if (grouped || detailed) {
      divbody = Div('plrg_body_gouped');
    } else {
      divbody = Div('plrg_body');
    }
    for (List<String> p in input) {
      if (p.length < 2) {
        return;
      }
      PlrView plrv = new PlrView(this, p, detailed);
      divlist.append(plrv.divlist);
      divbody.append(plrv.divbody);
    }
  }
  static void append(String ownerName, List<String> input) {
    String name = input[0];
    if (PlrView.dict.containsKey(name)) {

    } else {
      PlrView plr = PlrView.dict[ownerName];
      PlrGroup grp = plr.group;
      PlrViewAdd addplr = new PlrViewAdd(grp, input, false);
      addplr.parent = plr;
      addplr.sglDiv.attributes['class'] = 'sgl';
      (plr.divlist.parent as DivElement).insertBefore(addplr.divlist, plr.divlist.nextElementSibling);
      addplr.divlist.style.display = 'none';
    }
  }
}

class PlrView {
  static int pid = 0;
  static Map<String, PlrView> dict = {};

  static String replaceAddStr(String str) {
    int pos = str.indexOf('+');
    if (pos > -1) {
      return str.substring(0, pos) + '<span class="small">' + str.substring(pos) + '</span>';
    }
    return str;
  }

  PlrGroup group;
  PlrView parent;

  int score = 0;
  int kills = 0;
  String killedby;
  void addKill(){
    if (parent != null) {
      parent.addKill();
    } else {
      kills++;
    }
  }
  void addScore(int n) {
    if (parent != null) {
       parent.addScore(n);
     } else {
       score += n;
     }
  }

  DivElement divlist = Div('plr_list');
  DivElement divbody;
  DivElement sglDiv = Div('sgl');
  DivElement namediv = Div('name');

  DivElement maxhpDiv = Div('maxhp');
  DivElement oldhpDiv = Div('oldhp');
  DivElement hpDiv = Div('hp');

  int pcssid = ++pid;
  String pcss;

  String idName;
  String dispName;
  String fullName;

  String nameDivString;
  String nameHpDivString;
  String sglName;
  PlrView(this.group, List<String> input, bool detailed) {
    pcss = 'pid$pcssid';

    if (detailed) {
      divbody = Div('plr1');
    } else {
      divbody = Div('plr0');
    }
    idName = input[0];
    dispName = input[1];
    dict[idName] = this;
    sglName = input[2];
    fullName = input[3];

    if (detailed) {
      namediv.text = ' $idName ';
    } else {
      namediv.text = ' $dispName ';
    }

    sglDiv.classes.add(Sgls.getSglCss(sglName));
    if (sglName.endsWith(Dt.atex)) {
      // boss
      namediv.text = ' $dispName ';
    }
    String hpStr = input[4];
    int hpAddPos = hpStr.indexOf('+');
    if (hpAddPos > -1) {
      lastHp = int.parse(hpStr.substring(0, hpAddPos));
      hpStr = hpStr.substring(hpAddPos);
    } else {
      lastHp = int.parse(input[4]);
      hpStr = null;
    }

    String hpWidth = hpToWidth(lastHp);
    maxhpDiv.style.width = hpWidth;

    divbody
        ..append(sglDiv)
        ..append(namediv);
    int nameAddPos = fullName.indexOf('+');
    if (nameAddPos > -1) {
      divbody.append(Span('small')..text = fullName.substring(nameAddPos));
      divbody.appendText(' ');
    }

    nameDivString = '<div class="plr_body $pcss">${sglDiv.outerHtml}<div class="name"> $dispName </div></div>';
    nameHpDivString = '<div class="plr_body $pcss">${sglDiv.outerHtml}<div class="name"> $dispName </div><div class="maxhp" style="width: $hpWidth" /></div>';
    if (detailed) {
      DivElement detaildiv = Div('detail');
      divbody..append(new Text(l('HP', 'HP') + ' $lastHp'));
      if (hpStr != null) {
        divbody.append(Span('small')..text = hpStr);
      }
      divbody.append(detaildiv);
      divbody.append(new BRElement());
      int n = 5;
      String replaceAtt(Match m){
        return replaceAddStr(input[n++]);
      }
      detaildiv.setInnerHtml(l(' 攻 [] 防 [] 速 [] 敏 [] 魔 [] 抗 [] 智 []', 'detail').replaceAllMapped('[]', replaceAtt));
      if (input[12] != '') {
        switch (input[12]) {
          case '2':
            detaildiv.appendHtml(' ' + Dt.s_elite3, validator:noValidator);
            break;
          case '1':
            detaildiv.appendHtml(' ' + Dt.s_elite2, validator:noValidator);
            break;
          case '0':
            detaildiv.appendHtml(' ' + Dt.s_elite1, validator:noValidator);
            break;
          default:
            detaildiv.appendHtml(' ' + Dt.s_boss, validator:noValidator);
        }
      }
    }

    sglDiv = sglDiv.clone(true) as DivElement;
    namediv = namediv.clone(true) as DivElement;
    namediv.text = ' $dispName ';
    divlist
        ..append(sglDiv)
        ..append(namediv)
        ..append(maxhpDiv..append(oldhpDiv)..append(hpDiv));
    updateHp(lastHp);
  }
  int lastHp = 0;
  void updateHp(int hp) {
    lastHp = hp;
    String hpWidth = hpToWidth(lastHp);
    oldhpDiv.style.width = hpWidth;
    hpDiv.style.width = hpWidth;
    if (hp <= 0) {
      divlist.style.opacity = '0.5';
    } else {
      divlist.style.opacity = '';
      divlist.style.display = '';
    }
  }
  void updateMaxHp(String maxhpWidth) {
    maxhpDiv.style.width = maxhpWidth;
    nameHpDivString = '<div class="plr_body $pcss"><div class="sgl ${Sgls.getSglCss(sglName)}"></div>${namediv.outerHtml}<div class="maxhp" style="width: $maxhpWidth" /></div>';

  }
}

class PlrViewAdd extends PlrView{
  PlrViewAdd(PlrGroup parent, List<String> input, bool detailed) : super(parent, input, detailed);
//  void updateHp(String hpWidth) {
//    super.updateHp(hpWidth);
//    if (hpWidth == '0px' || hpWidth == '0.0px' || hpWidth == '0') {
//      divlist.style.height = '';
//    } else {
//      divlist.style.opacity = '';
//    }
//  }
}
