part of md5.connector;

class End  {
  DivElement panel;
  DivElement endtitle;
  ButtonElement refreshPageBtn;

  Random rng = new Random();

  int count = 0;
  int next = 10;
  int delta = 10;
  End(){
    panel = document.querySelector('#endPanel') as DivElement;
    panel.style.display = 'none';
    refreshPageBtn = document.querySelector('#refreshPageBtn') as ButtonElement;
    endtitle = document.querySelector('#endtitle') as DivElement;

    endtitle.text = l('你已经玩了[0]局了','endMessage').replaceAll('[0]', count.toString());
    refreshPageBtn.text = l('继续游戏','continueGame');

    refreshPageBtn.onClick.listen(hideNavPanel);
  }
  bool checkEnded() {
    count ++;
    if (count >= next) {
      next += delta;
      delta += rng.nextInt(sqrt(delta).toInt());
      endtitle.text = l('你已经玩了[0]局了','endMessage').replaceAll('[0]', count.toString());
      panel.style.display = '';
      (document.querySelector('#endFrame') as IFrameElement).src = Dt.namerena_help + l('navigation.html','navigationLink');

       return true;
    }
    return false;
  }
  void pushNext() {
    next ++;
  }

  void hideNavPanel(MouseEvent e) {
    if (panel.style.display != 'none') {
      panel.style.display = 'none';
      (document.querySelector('#endFrame') as IFrameElement).src = '';
    }
  }
}
