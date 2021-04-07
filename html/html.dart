library md5.html;

import 'dart:math';

import '../md5.dart';
export '../md5.dart';
import '../lan.dart';
export '../lan.dart';
import '../rc4.dart';
export '../rc4.dart';
import '../tunnel.dart';
import 'dart:html';
import 'dart:js' as Js;
import 'dart:async';
import 'package:base2e15/base2e15.dart';
export 'package:base2e15/base2e15.dart';
import 'dart:convert';
import 'sgl.dart';
import '../helper.dart';

part 'alias.dart';
part 'plrview.dart';


part 'renderer.dart';

SpanElement Span(String cls) {
  return new SpanElement()..classes.add(cls);
}

DivElement Div(String cls) {
  return new DivElement()..classes.add(cls);
}
TableCellElement TD(TableRowElement tr){
  TableCellElement td = new TableCellElement();
  tr.append(td);
  return td;
}

ParagraphElement P(String cls) {
  return new ParagraphElement()..classes.add(cls);
}

class HtmlRenderer {
  DivElement plist = document.querySelector('.plist') as DivElement;
  DivElement pbody = document.querySelector('.pbody') as DivElement;
  final Engine f;
  Timer timer;

  bool grouped = false;
  bool detailed = false;

  static init() async{
    await Sgl.init();
    var lan = window.sessionStorage[h_('ll')];
    if (lan is String) {
      loadLan(json.decode(lan) as Map);
    }
  }
  int preboost = 3;
  HtmlRenderer(this.f) {
    if (plist == null) {
      return;
    }
    tunnelReadAsync(onNames);
    timer = new Timer(new Duration(milliseconds: 10), start);
    window.onResize.listen(onResize);
    onResize(null);
    welcome();
    window.onMessage.listen(onMessage);
  }
  void onMessage(MessageEvent e) {
    if (e.data == Dt.qq) {
      plrlen = 2000;
    }
  }
  void onResize(Event e) {
    int w = window.innerWidth;
    if (w < 500) {
      plist.classes
        ..remove('hlist')
        ..add('vlist');
      pbody.classes
        ..remove('hbody')
        ..add('vbody');
    } else {
      plist.classes
        ..remove('vlist')
        ..add('hlist');
      pbody.classes
        ..remove('vbody')
        ..add('hbody');
    }
  }



  void welcome() {

    var row = P('row');
    pbody.append(row);
    row.append(Span('welcome')
        ..text = l('名字竞技场','welcome'));
    row.append(Span('welcome2')
            ..text = l('(MD5大作战10周年纪念)','welcome2'));
    if (f.error != null) {
      pbody.appendText(f.error);
    }
  }

  int token = rng.nextInt(256);
  void start() {
    f.start(token);
  }

  int plrlen = 2;
  List<List<List<String>>> _initList;
  void onNames(String str) {
    debug(str);
    if (str.length < 6) {
      return;
    }
    var bytes = Base2e15.decode(str);
    List<List<List<String>>> groupraw = utf8
        .decode(bytes
            .sublist(0, bytes.length - 8)
            .reversed
            .map((int b) => b ^ token)
            .toList())
        .split('\n')
        .map((str) {
      return str.split('\r').map((str) {
        return str.split('\t');
      }).toList();
    }).toList();
    if (groupraw.length > 1) {
      if (groupraw[0][0][0] != '') {
        // init data
        for (List<List> group in groupraw) {
          if (group.length > 1) {
            grouped = true;
          }
          for (List plraw in group) {
            if (plraw.length > 7) {
              detailed = true;
            }
          }
        }
        List<List<String>> noPlayers = [];
        for (List<List<String>> group in groupraw) {
          if (group.length==1 && (group[0] as List).length < 3) {
            if ((group[0] as List).length > 1) {
              // no player
              noPlayers.add(group[0]);
            } else {
              // blank user?
            }


            continue;
          }
          PlrGroup grp = new PlrGroup(group, grouped, detailed);
          plist.append(grp.divlist);
          pbody.append(grp.divbody);
        }
        for (List<String> noPlr in noPlayers) {
          ParagraphElement pel = P('row');
          pel.text = noPlr[1];
          pbody.append(pel);
        }
      }

      pbody.append(new HRElement());
      pbody.append(new BRElement());

      plrlen = PlrView.dict.length;
      if (plrlen > 10) {
        plrlen = 10;
      }
      plrlen += preboost;
      if (plrlen > 2000) {
        plrlen = 2000;
      }
      if ( _updates != null) {
        // protection of double update
        return;
      }
      nextUpdate();
      _initList = groupraw;
      for (List<List> l1 in _initList) {
        for (List l2 in l1) {
          l2.length = 4;
        }
      }
    } else {
      List<List<String>> padd = groupraw[0];
      PlrGroup.append(padd[0][0], padd[1]);
    }

  }

  RunUpdates _updates;

  nextUpdate() async{
    timer = null;
    DivElement div;
    if (_updates == null || _updates.updates.isEmpty) {
      _updates = await f.nextUpdates();
      await new Future.delayed(new Duration(milliseconds:1));
      _lastRow = null;
      _newTurnRow = true;
      _nextWait = 1800;
    }
    if (_updates == null) {
      return;
    }
    renderUpdate(_updates.updates.removeAt(0));
  }
  int _nextWait = 0;
  RunUpdate _rendering;
  bool fastShowCheckScroll = true;
  void renderUpdate(RunUpdate update) {
    if (timer != null) {
      debug('timer not cleared');
    }

    if (update == RunUpdate.newline) {
      _lastRow = null;
      fastShowCheckScroll = true;
      nextUpdate();
      return;
    }

    int wait = update.delay0;
    if (wait < _nextWait) {
      wait = _nextWait;
    }
    _nextWait = update.delay1;

    _rendering = update;
    if (plrlen >= 2000 && !(_updates == null || _updates.updates.isEmpty)) {
      _doRenderUpdate(fastShowCheckScroll);
      fastShowCheckScroll = false;
    } else {
      timer = new Timer(new Duration(milliseconds:wait  ~/ sqrt(plrlen/2).round()), _doRenderUpdate);
    }
  }

  ParagraphElement _lastRow;
  bool _newTurnRow = true;
  void _doRenderUpdate([bool checkScroll = true]) {
    if (checkScroll) {
      int maxScroll = pbody.scrollHeight - pbody.clientHeight;
      checkScroll = (maxScroll - pbody.scrollTop) < 50 ||  (pbody.scrollTop / maxScroll) > 0.95;
    }

    if (_rendering is RunUpdateWin) {
      win();
    } else {
      if (_lastRow == null) {
        _lastRow = P('row');
        pbody.append(_lastRow);
        if (_newTurnRow) {
          _newTurnRow = false;
        } else {
          _lastRow.setInnerHtml(' ');
          //_lastRow.text = ' ';
        }
      } else {
        _lastRow.appendText(', ');
      }
      _lastRow.append(_updateToHtml(_rendering));


      nextUpdate();
    }

    if (checkScroll) {
      pbody.scrollTop = pbody.scrollHeight - pbody.clientHeight;
    }
  }


  void win() {
    pbody.append(new BRElement());

    //TODO add hp to score

    String winnerName = _rendering.caster.idName;
    PlrView plr = PlrView.dict[winnerName];
    PlrGroup grp = plr.group;
    List<PlrView> winners = new List<PlrView>();
    List<PlrView> losers = new List<PlrView>();
    List winnerPost = [];
    PlrView.dict.forEach((n, p) {
      if (p.parent == null) {
        if (p.group == grp) {
          winners.add(p);
          winnerPost.add(p.idName);
        } else {
          losers.add(p);
        }
      }
    });
    winners.sort(sortPlrView);
    losers.sort(sortPlrView);


    TableElement table = new TableElement();

    void addPlrToTable(PlrView p) {
      TableRowElement tr = new TableRowElement();
      TD(tr)..appendHtml(p.divlist.outerHtml, validator:noValidator)..classes.add('namdtd');
      TD(tr)..text = p.score.toString();
      TD(tr)..text = p.kills.toString();
      if (p.killedby != null) {
        PlrView killer = PlrView.dict[p.killedby];
        TD(tr)..appendHtml(killer.nameDivString)..classes.add('namdtd');;
      } else {
        TD(tr);
      }
      table.append(tr);
    }

    TableRowElement tr = new TableRowElement();
    TD(tr)..setInnerHtml(Dt.s_win + l('胜者', 'winnerName') + Dt.s_win, validator:noValidator)..style.minWidth = '112px'..style.height = '32px';
    TD(tr)..text = l('得分','score')..style.width = '44px';
    TD(tr)..text = l('击杀','killedCount')..style.width = '44px';
    TD(tr)..text = l('致命一击','killerName')..style.minWidth = '112px';
    tr.style.background = '#FAFAFA';
    table.append(tr);

    for(PlrView p in winners) {
      addPlrToTable(p);
    }

    tr = new TableRowElement();
    TD(tr)..setInnerHtml(Dt.s_lose + l('败者', 'loserName') + Dt.s_lose, validator:noValidator)..style.height = '32px';
    TD(tr)..text = l('得分','score');
    TD(tr)..text = l('击杀','killedCount');
    TD(tr)..text = l('致命一击','killerName');
    tr.style.background = '#FAFAFA';
    table.append(tr);

    for(PlrView p in losers) {
      addPlrToTable(p);
    }

    pbody.append(table);

   DivElement btnBar = Div('buttonBar');
   pbody.append(btnBar);

   ButtonElement btn;

   btn = new ButtonElement();
   btn.text = l('返回', 'returnTitle');
   btnBar.append(btn);
   btn.onClick.listen((Event e){
     window.parent.postMessage({'button':'refresh'}, "*");
   });

   btn = new ButtonElement();
   btn.text = l('分享', 'shareTitle');
    btnBar.append(btn);

    btn.onClick.listen((Event e){
      window.parent.postMessage({'button':'share'}, "*");
    });

    btn = new ButtonElement();
    btn.text = l('帮助', 'helpTitle');
    btnBar.append(btn);
    String wikiLink = Dt.namerena_help;
    btn.onClick.listen((Event e){
      window.open(wikiLink, '_blank');
    });


    btnBar.style.marginLeft = '${table.offsetWidth - btnBar.offsetWidth -8}px';

    if (window.parent != window) {
      PlrView first = PlrView.dict[_initList[0][0][0]];
      ()async{
        await new Future.delayed(new Duration(milliseconds:1));
        // run this one frame later to ensure images are in cache
        CanvasElement canvas = toCanvas(winners, losers);
        Map postData = {
          'winners':winnerPost,
          'all':_initList,
          'pic':canvas.toDataUrl(),
          'firstKill':first.killedby
          };
        window.parent.postMessage(postData, "*");
      }();
    }
  }

  static num drawText(CanvasRenderingContext2D ctx, String txt, int x, int y, int w,  bool center) {
    TextMetrics tm = ctx.measureText(txt);
    if (center && tm.width < w) {
      x += (w - tm.width)~/2;
    }
    ctx.fillText(txt, x, y+15, w);
    return tm.width;
  }

  static ImageElement img = new ImageElement();
  static void drawPlr(CanvasRenderingContext2D ctx, PlrView p, int x, int y) {
    img.src = Sgls.dataUrls[p.sglName];
    ctx.drawImage(img, x+4, y+6);
    drawText(ctx, p.dispName, x+24, y+5, 90, false);
  }

  static CanvasElement toCanvas(List<PlrView> winners, List<PlrView> losers) {
    CanvasElement canvas = new CanvasElement();

    int sizemul = 1;
    if (winners.length + losers.length <= 128) {
      sizemul = 2;
    }
    canvas.width = 320*sizemul;
    canvas.height = ((winners.length + losers.length) * 26 + 88)*sizemul + 24;
    CanvasRenderingContext2D ctx = canvas.context2D;
    ctx.imageSmoothingEnabled = false;
    ctx.fillStyle = 'white';
    ctx.fillRect(0,0,canvas.width,canvas.height);
    if (sizemul != 1) {
      ctx.transform(sizemul,0,0,sizemul,0,0);
    }


    ctx.font = document.body.getComputedStyle().font;

    ctx.fillStyle = "#000000";
    num welcomw = drawText(ctx, "⇜　${l('名字竞技场','welcome')}　⇝", 0, 4, 320, true);

    int ctxh = 26;
    ctx.fillStyle = "#FAFAFA";
    ctx.fillRect(0,ctxh,320,32);
    ctx.fillStyle = "#EEEEEE";
    ctx.fillRect(0,ctxh,320,2);
    ctx.fillStyle = "#000000";
    num txtw = drawText(ctx, l('胜者', 'winnerName'), 0, ctxh+8, 114, true);
    drawText(ctx, l('得分','score'), 114, ctxh+8, 46, true);
    drawText(ctx, l('击杀','killedCount'), 160, ctxh+8, 46, true);
    drawText(ctx, l('致命一击','killerName'), 206, ctxh+8, 114, true);
    img.src = 'data:image/gif;base64,R0lGODlhFAAUALMAAAAAAP///98AJDsBRb3L09fi6NHf5ur2/JbFU63abcPuhcLthc/1mf///wAAAAAAACH5BAEAAA0ALAAAAAAUABQAAASCsMk5x6A4y6Gu/pyCXMJUaqGiJELbtCc1MOqiwnhl7aq675WAUGgIDYaBQ7FxTA4OyuIRengalr+fL2thWnrgcKLLLFS53ALh0nxWoe64mi1s1++BwZyJt+fre3p/g356axuEfQEFA4cbjIp5c44beowFl2sEax4yjY2aoZ0ZaEAUEQA7';
    ctx.drawImage(img, (114-txtw)~/2 - 24, ctxh+6);
    ctx.drawImage(img, (114+txtw)~/2 + 4 , ctxh+6);
    ctxh += 32;

    for (PlrView winner in winners) {
      ctx.fillStyle = "#EEEEEE";
      ctx.fillRect(0, ctxh, 320, 2);

      ctx.fillStyle = '#ddddd0';
      ctx.fillRect(22, ctxh+4, winner.maxhpDiv.offsetWidth, 2);
      ctx.fillStyle = '#4c4';
      ctx.fillRect(22, ctxh+4, (winner.lastHp /4).ceil(), 2);

      ctx.fillStyle = "#000000";
      drawPlr(ctx, winner, 0, ctxh);
      drawText(ctx, winner.score.toString(), 114, ctxh+5, 46, true);
      drawText(ctx, winner.kills.toString(), 160, ctxh+5, 46, true);
      if (winner.killedby != null) {
        PlrView killer = PlrView.dict[winner.killedby];
        drawPlr(ctx, killer, 206, ctxh);
      }
      ctxh += 26;
    }

     ctx.fillStyle = "#FAFAFA";
     ctx.fillRect(0,ctxh,320,32);
     ctx.fillStyle = "#EEEEEE";
     ctx.fillRect(0,ctxh,320,2);
     ctx.fillStyle = "#000000";
     drawText(ctx, l('败者', 'loserName'), 0, ctxh+8, 114, true);
     drawText(ctx, l('得分','score'), 114, ctxh+8, 46, true);
     drawText(ctx, l('击杀','killedCount'), 160, ctxh+8, 46, true);
     drawText(ctx, l('致命一击','killerName'), 206, ctxh+8, 114, true);
     img.src = 'data:image/gif;base64,R0lGODlhFAAUAMQAAAAAAP///98AJDsBRd3y/vv+/4m4RpbFU6LPYqLOYqLPY6PPY6HNYq3abazYbbfgfcPuhc/1mdL1n9/9td78td36tHqpNYi3Q4i2Q4azQ5/JYZzEYMPqiv39/f///wAAACH5BAEAAB4ALAAAAAAUABQAAAWOoCeO4zCQaCoO0Km+LHScwlirMQQ1Qu/1N9IgoisCj6hhZFLcHYOryLKp4/mE0gmT6nStJBXKlru7eAcSMrXRcLHS6iLbcjLZ7cX73RPrEAhqfgR0fBASHQWAZIiDdQgNHZGBBR1mK5CSi5FnGpSKa5EEXnyeXGyeKaEOegMIoSkEfgMJCwkKDAYDsQQjIQA7';
     ctx.drawImage(img, (114-txtw)~/2 - 24, ctxh+6);
     ctx.drawImage(img, (114+txtw)~/2 + 4 , ctxh+6);

     ctxh += 32;

     for (PlrView loser in losers) {
       ctx.fillStyle = "#EEEEEE";
       ctx.fillRect(0, ctxh, 320, 2);

       ctx.fillStyle = "#000000";
       drawPlr(ctx, loser, 0, ctxh);
       drawText(ctx, loser.score.toString(), 114, ctxh+5, 46, true);
       drawText(ctx, loser.kills.toString(), 160, ctxh+5, 46, true);
       if (loser.killedby != null) {
         PlrView killer = PlrView.dict[loser.killedby];
         drawPlr(ctx, killer, 206, ctxh);
       }
       ctxh += 26;
     }
     ctx.fillStyle = "#F8F8F8";
     ctx.fillRect(0, ctxh, 320, 2);
     try {
       ctx.resetTransform();
       ctxh *= sizemul;
       ctx.fillStyle = "#888888";
       drawText(ctx, Dt.namerena_domain, 0, ctxh+2, 140, false);
     } catch (err) {

     }

    return canvas;
  }

  static int sortPlrView(PlrView p1, PlrView p2) {
    if (p1.score == p2.score) {
      return p1.pcssid - p2.pcssid;
    }
    return p2.score - p1.score;
  }
}
