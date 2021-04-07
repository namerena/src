part of md5;


abstract class NonePlr extends Plr {
  NonePlr(String baseName, String c, String s) : super(baseName, c, s);
  String toMessage();
}
class PlrSeed extends NonePlr {
  PlrSeed(String baseName) : super(baseName, Dt.ex, '${Dt.seed}${Dt.atex}') {
    dispName = baseName.substring(5);
  }
  String toMessage() {
    return baseName;
  }
}

