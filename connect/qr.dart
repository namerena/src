part of md5.connector;

class Qr  {

  static Qr instance;

  static List<int> capacity = [0, 17,32,53,78,106,134,154,192,230,271,321,367,425,458,520,586,644,718,792,858,929,1003,1091,1171,1273,1367,1465,1528,1628,1732,1840,1952,2068,2188,2303,2431,2563,2699,2809,2953];
  CanvasElement canvas;
  Qr(bool use){
    instance = this;
    canvas = document.querySelector('#qrCanvas') as CanvasElement;
  }

  void update(String value, String value2) {
    if (value.length > 858) {
      value = value2;
    }
    int type = 3;
    for (type = 3; type <= 35; ++type) {
      if (capacity[type] >= value.length) {
        break;
      }
    }
    if (type > 35) {
      canvas.style.display = 'none';
      return;
    }
    int size = type*4 +17;
    int pxs = 314 ~/ size;
    if (pxs > 6) {
      pxs = 6;
    }
    int canvasSize = pxs * size;
    canvas.height = canvasSize;
    canvas.width = canvasSize;
    try {
      QrCode qr = new QrCode(type, 1);
      qr.addData(value);
      qr.make();
      var ctx = canvas.context2D;
      ctx.fillStyle = "#FFF";
      ctx.fillRect(0, 0, canvasSize, canvasSize);
      ctx.fillStyle = "#000";
      for (int y = 0; y < size; ++y)
        for (int x = 0; x < size; ++x) {
          if (qr.isDark(y, x)) {
            ctx.fillRect(x*pxs, y*pxs, pxs, pxs);
          }
        }

    } catch(err, stack) {
      canvas.style.display = 'none';
      print(stack);
      return;
    }
    canvas.style.display = '';
  }
}
