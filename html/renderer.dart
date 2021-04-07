part of md5.html;

final RegExp _updateReg = new RegExp(r'\[.*?\]');

String hpToWidth(num n) {
  return '${(n/4).ceil()}px';
}

Element _updateToHtml(RunUpdate update) {

  if (update.score > 0 && update.caster != null) {
    PlrView plv = PlrView.dict[update.caster.idName];
    plv.addScore(update.score);
  }

  List<IPlr> toupdate = [];

  String _renderItem(Object obj) {
    if (obj is NPlr) {
      PlrView plv = PlrView.dict[obj.idName];
      return plv.nameDivString;
    }
    if (obj is HPlr) {
      PlrView plv = PlrView.dict[obj.idName];
      plv.updateHp(obj.newHp);
      obj.pcss = plv.pcss;
      toupdate.add(obj);
      return plv.nameHpDivString;
    }
    if (obj is DPlr) {
      PlrView plv = PlrView.dict[obj.idName];
      if (update.caster != null) {
        plv.killedby = update.caster.idName;
        PlrView casterPlv = PlrView.dict[plv.killedby];
        casterPlv.addKill();
      }
      plv.updateHp(0);
      toupdate.add(obj);
      return plv.nameDivString;
    }
    if (obj is MPlr) {
      PlrView plv = PlrView.dict[obj.idName];
      plv.updateHp(obj.newHp);
      plv.updateMaxHp(hpToWidth(obj.maxHp));
      return plv.nameDivString;
    }
    if (obj is HDamage) {
      return '<div class="damage">${obj.damage}</div>';
    }

    if (obj is HRecover) {
      return '<div class="recover">${obj.recover}</div>';
    }

    return obj.toString();
  }

  String updateMap(Match m) {
    String g0 = m.group(0);
    if (g0== '[0]') {
      return _renderItem(update.caster);
    } else if (g0 == '[1]') {
      return _renderItem(update.target);
    } else if (g0 == '[2]') {
      return _renderItem(update.param);
    } else if (update is RunUpdateCancel){
      return '<span class="sctext">${g0.substring(1, g0.length-1)}</span>';
    } else {
      return '<span class="stext">${g0.substring(1, g0.length-1)}</span>';
    }
  }
  SpanElement span = Span('u')..setInnerHtml(update.message.replaceAllMapped(_updateReg, updateMap), validator:noValidator);

  for (IPlr plr in toupdate) {
    if (plr is HPlr) {
      DivElement maxHpDiv = span.querySelector('.${plr.pcss} > .maxhp') as DivElement;
      if (plr.oldHp >= plr.newHp) {
        // damaged
        DivElement oldHp = Div('oldhp')..style.width = hpToWidth(plr.oldHp);
        DivElement newHp = Div('hp')..style.width = hpToWidth(plr.newHp);;
        maxHpDiv.append(oldHp);
        maxHpDiv.append(newHp);
      } else {
        // healed
        DivElement healHp = Div('healhp')..style.width = hpToWidth(plr.newHp);
        DivElement newHp = Div('hp')..style.width = hpToWidth(plr.oldHp);
        maxHpDiv.append(healHp);
        maxHpDiv.append(newHp);
      }
    } else if (plr is DPlr) {
      DivElement div = span.querySelector('.name') as DivElement;
      div.classes.add('namedie');
    }



  }

  return span;
}

//Element _damageToHtml(RunUpdateDamage update) {
//
//  String _renderHpName(Object obj) {
//    if (obj is Plr) {
//      PlrView plv = PlrView.dict[obj.name];
//      return plv.nameHpDivString;
//    } else {
//      return obj.toString();
//    }
//  }
//
//  String updateMap(Match m) {
//    String g0 = m.group(0);
//    if (g0== '[0]') {
//      return _renderItem(update.caster);
//    } else if (g0 == '[1]') {
//      return _renderHpName(update.target);
//    } else if (g0 == '[2]') {
//      return _renderDamage(update.param);
//    } else {
//      return '<span class="stext">${g0.substring(1, g0.length-1)}</span>';
//    }
//  }
//  SpanElement span = Span('u')..setInnerHtml(update.message.replaceAllMapped(_updateReg, updateMap), validator:_noValidator);
//  DivElement maxHpDiv = span.querySelector('.maxhp');
//  DivElement oldHp = Div('oldhp')..style.width = hpToWidth(update.oldHp);
//  String newWidth = hpToWidth(update.newHp);
//  DivElement newHp = Div('hp')..style.width = newWidth;
//  maxHpDiv.append(oldHp);
//  maxHpDiv.append(newHp);
//
//  return span;
//}
