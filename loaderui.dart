part of md5.loader;


class LoaderUi {

  static LoaderUi instance;

  static RegExp invalidChar = new RegExp(r'[\u0000-\u0003]');
  static String _addata_h = b('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script> <!-- narena --> <ins class="adsbygoogle"  style="display:inline-block;width:320px;height:100px"  data-ad-client="ca-pub-3283235194066083"  data-ad-slot="8508871459"></ins> <script> (adsbygoogle = window.adsbygoogle || []).push({}); </script>');
  static String _addata_v = b('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script> <!-- narena_v --> <ins class="adsbygoogle"  style="display:inline-block;width:300px;height:600px"  data-ad-client="ca-pub-3283235194066083"  data-ad-slot="7719051857"></ins> <script> (adsbygoogle = window.adsbygoogle || []).push({}); </script>');

  DivElement bodyLayer;
  DivElement inputPanel;
  DivElement sharePanel;
  TextAreaElement textarea;
  ButtonElement goBtn;
  DivElement controlBar;
  ButtonElement shareBtn;
  ButtonElement refreshBtn;
  ButtonElement fastBtn;

  ButtonElement closeBtn;
  ButtonElement shareCloseBtn;

  DivElement inputOptions;
  DivElement checkBoss;

  IFrameElement iframe;
  DivElement addiv_h;
  DivElement addiv_v;

  DivElement loaderBg;

  Qr qr = new Qr(true);
  End end = new End();

  BossSelector boss = new BossSelector();

  LoaderUi() {
    instance = this;

    bodyLayer = querySelector('.body') as DivElement;
    inputPanel = querySelector('#inputPanel') as DivElement;
    sharePanel = querySelector('#sharePanel') as DivElement;
    sharePanel.style.display = 'none';

    textarea = querySelector('#inputPanel textarea') as TextAreaElement;
    iframe = querySelector('.mdframe') as IFrameElement;
    addiv_h = querySelector('.ad_h') as DivElement;
    addiv_v = querySelector('.ad_v') as DivElement;
    querySelector('#inputtitle').text = l('名字竞技场','inputTitle');

    textarea.placeholder =
        l('每行输入一个名字  \n  \n组队对战时用空行隔开组队','inputPlaceholder');
    goBtn = querySelector('.goBtn') as ButtonElement;
    goBtn.text = l('开 始','startFight');
    goBtn.onClick.listen(onStart);

    controlBar = querySelector('.controlbar') as DivElement;
    controlBar.style.display = 'none';

    loaderBg = querySelector('.loaderbg') as DivElement;

    closeBtn =  querySelector('#inputPanel .closeBtn') as ButtonElement;
    closeBtn.onClick.listen(onClose);
    closeBtn.title =  l('关闭','closeTitle');
    closeBtn.style.display = 'none';


    querySelector('#sharetitle').text = l('分享','shareTitle');

    shareCloseBtn =  querySelector('#sharePanel .closeBtn') as ButtonElement;
    shareCloseBtn.onClick.listen(onClose);
    shareCloseBtn.title =  l('关闭','closeTitle');


    refreshBtn = querySelector('#refreshBtn') as ButtonElement;
    refreshBtn.onClick.listen(onRefresh);
    refreshBtn.title =  l('返回','returnTitle');

    fastBtn = querySelector('#fastBtn') as ButtonElement;
    fastBtn.onClick.listen(onFast);
    fastBtn.title =  l('快进','fastTitle');

    shareBtn = querySelector('#shareBtn') as ButtonElement;
    shareBtn.onClick.listen(onShare);
    shareBtn.title =  l('分享','shareTitle');

    checkBoss = querySelector('.checkBoss') as DivElement;
    checkBoss.onMouseDown.listen(onExpandBoss);

    inputOptions = querySelector('.inputoptions') as DivElement;

    String baseUrl = 'http://${Dt.namerena_domain}${window.location.pathname.substring(window.location.pathname.lastIndexOf("/"))}#n=';
    Base64UrlCodec.url = baseUrl;

    window.onResize.listen(onResize);
    onResize(null);

    window.onMessage.listen(onMessage);

    initLan();
    window.onHashChange.listen(onHashChange);
    onHashChange(null);

    document.onKeyDown.listen(onKeyDown);
  }
  String lanHash;
  void initLan(){
    String search = window.location.search;
    int pos = search.lastIndexOf('l=');
    if (pos > 0) {
      lanHash = search.substring(pos);
      String baseUrl = '${window.location.origin}${window.location.pathname}?$lanHash#n=';
      Base64UrlCodec.url = baseUrl;
    } else {
      lanHash = null;
    }
  }
  String lastHash;
  void onHashChange(Event e){
     String hash = window.location.hash;
     if (hash == lastHash) {
       return;
     }
     lastHash = hash;
     // read settings from hash
     if (hash.length > 1) {
       var parsed = Uri.splitQueryString(hash.substring(1));
       if (parsed['n'] != null) {
         textarea.value = Hashdown.decode(parsed['n']).text.split('\n').map((str)=>str.trim()).join('\n');
         onStart(null);
       }
       if (parsed.containsKey('b')) {
         // boss
         boss.bossNameChanged(parsed['b']);
         onExpandBoss(null);
       }
     }
     window.location.hash = '';
  }

  void onKeyDown(KeyboardEvent e) {
    if (e.altKey) {
      if (e.keyCode == 0x31) {
        if (inputPanel.style.display == '') {
          onStart(null);
        }
      } else if (e.keyCode == 0x32) {
        onRefresh(null);
      }
    }

  }

  void showLoader(){
    loaderBg.style.opacity = '0.3';
  }
  void hideLoader(){
    loaderBg.style.opacity = '0';
  }

  void addNames(List names, bool newGroup) {
    hideLoader();
    String str = textarea.value.trim().replaceAll(invalidChar, '');
    List oldNames = str.split('\n');
    if (str.isEmpty) {
      oldNames = [];
    }
    if (newGroup || oldNames.contains('')) {
      oldNames.add('');
    }
    for (var name in names) {
      if (name is String && !oldNames.contains(name)) {
        oldNames.add(name);
      }
    }
    textarea.value = oldNames.join('\n');
  }

  int emptyBossClick = 0;
  void onStart(Event e) {
    String str = textarea.value.trim().replaceAll(invalidChar, '');
    if (!inputOptions.style.height.startsWith('0')) {
      if (boss.bossName != null) {
        run('$str\n\n${boss.bossName}');
      } else {
        if (emptyBossClick > 2) {
          run('$str\n\nRinick+属性修改器');
        } else {
          ++emptyBossClick;
          return;
        }
      }
    } else {
      run(str);
    }

    onClose(e);
    shareBtn.style.display = 'none';
    fastBtn.style.display = '';
    closeBtn.style.display = '';
    textarea.value = str;
  }
  void onClose(Event e) {
    window.location.hash = '';
    hideLoader();
    sharePanel.style.display = 'none';
    inputPanel.style.display = 'none';
    controlBar.style.display = '';
    end.hideNavPanel(null);
  }

  void onRefresh(Event e) {
    if (end.checkEnded()) {
      return;
    }
    onClose(null);
    inputPanel.style.display = '';
    controlBar.style.display = 'none';
    textarea.focus();
  }
  void onFast(Event e) {
    iframe.contentWindow.postMessage(Dt.qq, '*');
  }
  void onShare(Event e) {
    onClose(null);
    TextAreaElement shareTextarea = querySelector('#sharePanel textarea') as TextAreaElement;
    bool needGroup = false;
    List<String> groupNames = _LastAll.map((List<List<String>> list){
      List<String> names = list.map((List<String> l2){
        if (l2[3] == null){
          // no player
          return l2[0];
        }
        return l2[3];
      }).toList();
      if (names.length > 1) {
        needGroup = true;
        return names.join('\n');
      } else {
        return names.first;
      }
    }).toList();
    String str;
    if (needGroup) {
      str = groupNames.join('\n\n');
    } else {
      str = groupNames.join('\n');
    }

    String url = Hashdown.encodeString(str, new HashdownOptions()..protect = Hashdown.PROTECT_RAW);
    int pos = url.lastIndexOf('#');
    String urlHash = url.substring(pos);
    if (urlHash.length < 1000) {
      lastHash = urlHash;
      window.location.hash = urlHash;
    }

    String baseUrl = 'http://${Dt.namerena_domain}${window.location.pathname.substring(window.location.pathname.lastIndexOf("/"))}';
    if (lanHash != null) {
      baseUrl = '$baseUrl?$lanHash';
    }

    shareTextarea.value = url;
    qr.update(url, baseUrl);

    controlBar.style.display = 'none';
    sharePanel.style.display = '';
    shareTextarea.focus();
    shareTextarea.select();
  }

  void onExpandBoss(Event e) {
    if (e == null || inputOptions.style.height.startsWith('0')) {
      checkBoss.classes.add('checkedBoss');
      inputOptions.style.opacity = '';
      inputOptions.style.height = '38px';
    } else {
      checkBoss.classes.remove('checkedBoss');
      inputOptions.style.height = '0';
      inputOptions.style.opacity = '0';
    }
  }

  List<List<List<String>>> _LastAll;
  void onMessage(MessageEvent e) {
    if (e.data is Map) {
      Map m = e.data as Map;
      if (m['add'] is List) {
        addNames(m['add'] as List, false);
      } else if (m['winners'] is List && m['all'] is List) {
        end.pushNext();

        _LastAll = (m['all'] as List).map((a)=>(a as List).map((b)=>(b as List).map((c)=>c as String).toList()).toList()).toList();

        if (window.parent != window) {
          m.remove('pic');
          m.remove('firstKill');
          m['all'] = _LastAll.map((List<List> group){
            return group.map((List plist)=>plist.first).toList();
          }).toList();
          window.parent.postMessage(m, '*');
        }

        shareBtn.style.display = '';
        fastBtn.style.display = 'none';
      } else if (m['button'] == 'share') {
        onShare(null);
      } else if (m['button'] == 'refresh') {
        onRefresh(null);
      } else if (m['button'] == 'showLoader') {
        showLoader();
      }
    }
  }

  String lastClass;
  void onResize(Event e) {
    int w = window.innerWidth;
    if (w >= 800) {
      initRightAd();
    } else {
      initBottomAd();
    }
  }

  void initBottomAd(){
    if (lastClass != 'body_v') {
      if (lastClass != null) {
        bodyLayer.classes.remove(lastClass);
      }
      lastClass = 'body_v';
      bodyLayer.classes.add(lastClass);
    }
    addiv_h.style.display = '';
    addiv_v.style.display = 'none';
    if (_addata_h != null) {
      addiv_h.setInnerHtml(_addata_h, validator:noValidator);
      _addata_h = null;
    }
  }
  void initRightAd(){
    if (lastClass != 'body_h') {
      if (lastClass != null) {
        bodyLayer.classes.remove(lastClass);
      }
      lastClass = 'body_h';
      bodyLayer.classes.add(lastClass);
    }
    addiv_v.style.display = '';
    addiv_h.style.display = 'none';
    if (_addata_v != null) {
      String weibolive = '';

      addiv_v.setInnerHtml('$weibolive$_addata_v', validator:noValidator);
      _addata_v = null;
    }
  }
  void initNoAd() {
    addiv_v.style.display = 'none';
    addiv_h.style.display = 'none';
  }
}
