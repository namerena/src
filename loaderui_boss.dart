part of md5.loader;


class BossSelector {
  DivElement bossSglDiv;
  DivElement bossNameDiv;
  DivElement showBossListDiv;
  DivElement bossList;
  BossSelector() {
    document.querySelector('.checkBoss').text = l('挑战Boss','challengeLabel');

    bossSglDiv = document.querySelector('.bossSgl') as DivElement;
    bossNameDiv = document.querySelector('.bossName') as DivElement;
    showBossListDiv = document.querySelector('.showBossList') as DivElement;
    bossList = document.querySelector('.bossList') as DivElement;
    document.querySelector('.showBossBtn').onMouseDown.listen(addBoss);

    bossNameChanged(null);
    initBossList();
  }

  void initBossList() {
    for (String key in [Dt.aokiji,Dt.conan,Dt.ikaruga,Dt.mario,Dt.mosquito,Dt.slime,Dt.sonic,Dt.yuri,Dt.lazy,Dt.saitama,Dt.covid]) {
      String val = Images.bosses[key];
      DivElement row = new DivElement()..classes.add('bossSelRow')..classes.add('horizontal');
      DivElement sgl = new DivElement()..classes.add('bossSgl');
      DivElement name = new DivElement()..classes.add('bossSelName');
      name.text =  L(h_('${Dt.bossName}$key'));
      sgl.style.background = 'url("data:image/gif;base64,' + val + '")';
      row.append(sgl);
      row.append(name);
      row.dataset['boss'] = key + '@!';
      row.onClick.listen(onRowClicked);
      bossList.append(row);
    };
  }
  String bossName;
  void bossNameChanged(String name) {
    if (name == null || name == '') {
      bossName = null;
      bossNameDiv.text = l('选择Boss','selectBossHint');
      bossNameDiv.style.opacity = '0.5';
      bossSglDiv.style.background = '';
    } else {
      bossName = name;
      String label = '';
      String img;
      if (name.endsWith('@!')) {
        String keyName = name.substring(0, name.length-2);
        label = L(h_('${Dt.bossName}$keyName'));
        img = Images.bosses[keyName];
      }
      if (label == '') {
        label = name;
      }
      bossNameDiv.text = label;
      bossNameDiv.style.opacity = '';
      if (img != null) {
        bossSglDiv.style.background =  'url("data:image/gif;base64,' + img + '")';
      } else {
        bossSglDiv.style.background =  '';
      }
    }
    bossList.classes.remove('menuopen');
    if (listener != null) {
      listener.cancel();
      listener = null;
    }
  }

  void onRowClicked(MouseEvent e){
    String name = (e.currentTarget as HtmlElement).dataset['boss'];
    bossNameChanged(name);
  }
  StreamSubscription listener;
  void addBoss(MouseEvent e) {
    bossList.classes.add('menuopen');
    e.stopPropagation();
    if (listener == null) {
      listener = document.body.onMouseDown.listen(onGlobalMouseDown);
    }
  }
  void onGlobalMouseDown(MouseEvent e) {
    if (!bossList.contains(e.target as Node) ) {
      bossNameChanged(null);
    }
  }
}
