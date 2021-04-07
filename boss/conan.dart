part of md5;

// l('柯南','bossName_conan')

class BossConan extends PlrBoss {
  BossConan(String baseName, String clanName) : super(baseName, clanName);

  List<int> get appendAttr => const  [0, 48, -33, 20, 0, 41, 30, 22];

  List<String> get immunedx => [Dt.charm];

  void createSkills() {
    dftAct = new SklConan(this);
  }
}


class SklConan extends ActionSkl {
  BossConan conan;
  SklConan(this.conan) {
    owner = conan;
  }

  int get selCount => 3;
  int get selCountSmart => 4;

  bool validTarget(Plr target, bool smart) {
     return target is! Minion;
   }

  int thinking = -1;
  void act(List<PlrScore> targets, bool smart, R r, RunUpdates updates) {
    while (targets == null) {
      targets = select(true, r);
    }
    Plr target = targets[0].p;
    if (thinking == -1 && targets.length == 1) {
      // first round and only one target
      thinking = 1;
      updates.add(new RunUpdate(l('[0]在一间密室中发现了一具无名尸体', 'sklConanKillUnknown'), owner));
      updates.add(RunUpdate.newline);
    }

    if (thinking > 0) {
      thinking--;
      updates.add(new RunUpdate(l('[0]正在进行推理','sklConanThinking'), owner));
      return;
    }

    int damaged = target.hp;
    target.hp = 0;


    if (targets.length == 1 && thinking == 0) {
      updates.add(new RunUpdate(l('[0]推理完毕','sklConanThinkingFinish'), owner));
      updates.add(new RunUpdate(l('真相只有一个','sklConanThinkingFinish2'), owner, null, null, null, null, 1000,2000));
      updates.add(new RunUpdate(l('凶手就是你','sklConanThinkingFinish3'), owner));
      updates.add(new RunUpdate(l('[1]','sklConanKillLast'),owner, new HPlr(target, damaged), new HDamage(damaged), null, damaged + 80));
    } else {
      thinking = 1;
      updates.add(new RunUpdate(l('[0]在一间密室中发现了[1]的尸体','sklConanKill'), owner, new HPlr(target, damaged), new HDamage(damaged), null, damaged + 80));
    }
    target.onDie(damaged, owner, r, updates);
    owner.spsum += target.group.alives.length  * 1000;
    if (owner.spsum > 3000) {
      owner.spsum = 3000;
    }
  }
}
