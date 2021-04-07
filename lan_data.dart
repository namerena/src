part of md5.lan;


String b(String str) {
  return str;
}
String smile(String str) {
  return '<div class="smile s_$str"></div>';
}

String l(String str, String key) {
  return str;
}

void debug(Object str) {
  print(str);
}

Map<String, String> _L = {};

String L(String key) {
  String rslt = _L[key];
  if (rslt == null) {
    return '';
  }
  return rslt;
}
void loadLan(Map m) {
   m.forEach((k,v){
     if (v is String && !v.contains('<') && !v.contains('>')) {
       _L[h_(k as String)] = v;
     }
   });
}

class Dt {

  static String ex = b('!');
  static String add = b('+');
  static String at = b('@');
  static String atex = b('@!');
  static String cln = b(':');
  static String exTest = b('!test!');

  static String u02 = b('\u0002');
  static String u03 = b('\u0003');
//  static String u04 = b('\u0004');
//  static String u05 = b('\u0005');
//  static String u200b = b('\u200B');

  static String qq = b('??');

  static String assassinate = b('assassinate');
  static String exchange = b('exchange');
  static String half = b('half');

  static String charge = b('charge');
  static String fire = b('fire');
  static String ice = b('ice');
  static String accumulate = b('accumulate');
  static String poison = b('poison');
  static String berserk = b('berserk');
  static String charm = b('charm');
  static String curse = b('curse');
  static String iron = b('iron');
  static String slow = b('slow');
  static String haste = b('haste');
  static String corpose = b('corpose');
  static String shield = b('shield');
  static String protect = b('protect');
  static String upgrade = b('upgrade');
  static String disperse = b('disperse');


  static String zombie = b('zombie');
  static String shadow = b('shadow');
  static String summon = b('summon');
  static String minionCount = b('minionCount');

  static String bossName = b('bossName_');

  static String mario = b('mario');
  static String sonic = b('sonic');
  static String mosquito = b('mosquito');
  static String yuri = b('yuri');
  static String slime = b('slime');
  static String ikaruga = b('ikaruga');
  static String conan = b('conan');
  static String aokiji = b('aokiji');
  static String lazy = b('lazy');
  static String covid = b('covid');
  static String saitama = b('saitama');

  static String rinick = b('Rinick');

  static String hanxu = b('涵虚');
  static String lingyun = b('霛雲');
  static String yunjian = b('云剑');
  static String xinjiyuan = b('新纪元');
  static String kuzan = b('库瓒');
  static String kuzan1 = b('庫瓒');
  static String qilala = b('琪拉拉');
  static String chuncai = b('纯菜');
  static String xueche = b('学🚗🀄学');
  static String phy = b('Ø');

  static String seed = b('seed:');
  static String dio = b('dio');

  static String mask = b('mask');
  static String maskz = b('口罩');
  static String ladderz = b('天梯');

  static String s_win = b('<div class="smile s_win"></div>');
  static String s_lose = b('<div class="smile s_lose"></div>');
  static String s_elite1 = b('<div class="smile s_elite1"></div>');
  static String s_elite2 = b('<div class="smile s_elite2"></div>');
  static String s_elite3 = b('<div class="smile s_elite3"></div>');
  static String s_boss = b('<div class="smile s_boss"></div>');
  static String s_dmg0 = b('<div class="smile s_dmg0"></div>');
  static String s_dmg120 = b('<div class="smile s_dmg120"></div>');
  static String s_dmg160 = b('<div class="smile s_dmg160"></div>');
  static String s_accumulate = b('<div class="s_accumulate s_win"></div>');
  static String s_berserk = b('<div class="smile s_berserk"></div>');
  static String s_charm = b('<div class="smile s_charm"></div>');
  static String s_curse = b('<div class="smile s_curse"></div>');
  static String s_exchange = b('<div class="smile s_exchange"></div>');
  static String s_haste = b('<div class="smile s_haste"></div>');
  static String s_ice = b('<div class="smile s_ice"></div>');
  static String s_iron = b('<div class="smile s_iron"></div>');
  static String s_poison = b('<div class="smile s_poison"></div>');
  static String s_revive = b('<div class="smile s_revive"></div>');
  static String s_slow = b('<div class="smile s_slow"></div>');
  static String s_counter = b('<div class="smile s_counter"></div>');
  static String s_reflect = b('<div class="smile s_reflect"></div>');
  static String s_upgrade = b('<div class="smile s_upgrade"></div>');

  static String namerena_domain = b('deepmess.com/namerena');
  static String namerena_help = b('https://deepmess.com/zh/namerena/');

}

