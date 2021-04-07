part of md5.sig;


class Sgl {
  static List<List<int>> sig_colors = <List<int>>[
    [255, 255, 255],
    [255, 255, 255],
    [0, 0, 0],
//    [0, 0, 128],
//    [0, 120, 128],
//    [128, 0, 128],
    [0, 180, 0],
    [0, 255, 0],
//    [128, 224, 0],
    [255, 0, 0],

    [255, 192, 0],
    [255, 255, 0],
    [0, 224, 128],
//    [128, 224, 128],
    [255, 0, 128],
    [255, 108, 0],
//    [255, 120, 128],
//    [255, 224, 128],

    [0, 108, 255],
    [0, 192, 255],
    [0, 255, 255],

    [128, 120, 255],
    [128, 224, 255],
    [255, 0, 255],
///    [255, 160, 255],
//    [128, 128, 128],
    [40, 40, 255],
    [128, 0, 255],
///    [180, 180, 180],
    [0, 144, 0],
    [144, 0, 0],
///    [144, 128, 0],

  ];
  static int cCount = sig_colors.length;
  static List<List<double>> cdif = () {
    // distance of colors
    List<List<double>> dds = new List<List<double>>(cCount);
    for (int i = 0; i < cCount; ++i) {
      dds[i] = new List<double>(cCount);
      dds[i][i] = 0.0;
    }
    for (int i = 1; i < cCount; ++i) {
      for (int j = 0; j < i; ++j) {
        double dr = (sig_colors[i][0] - sig_colors[j][0]) * 0.3;
        double dg = (sig_colors[i][1] - sig_colors[j][1]) * 0.4;
        double db = (sig_colors[i][2] - sig_colors[j][2]) * 0.25;
        double dl = (sig_colors[i][0] * 0.15 +
                sig_colors[i][0] * 0.25 +
                sig_colors[i][0] * 0.1) -
            (sig_colors[j][0] * 0.15 +
                sig_colors[j][0] * 0.25 +
                sig_colors[j][0] * 0.1);
        double d = Math.sqrt(dr * dr + dg * dg + db * db + dl * dl);
        dds[j][i] = d;
        dds[i][j] = d;
      }
    }

    return dds;
  }();

  static ImageElement _pattern;
  static Completer<String> _initComplete = new Completer<String>();
  static Future<String> init() {
    Sgls.loadBossSgls();
    _pattern = new ImageElement();
    _pattern.onLoad.listen(onPatternLoaded);
    _pattern.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACAAgMAAAC+UIlYAAAADFBMVEX/AAD/AP8A/wD///8SU+EWAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3wwaCg0BGtaVrQAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAADHUlEQVRYw+2WPY6jMBTHLejhMNOu4BRkpTTp5xIgzQGmilKmSjFUkbZFCpp6tN3mHGikpAK8/r/nZwhxMlllViOtFsWxsX/2+7SNKj941E7r/lr5Q6BNuW5iqqtv3xLlBtKW67jpd3XY75SyAF4wAwMAwpqLAVgEADuDANOu4iahCQ7AIAaUSrBalbYEDCI+BESPiyJk0KukmCnlzMybHHVXLD4M9w35oIJC6R4FbVm6UNw2QB0UoQcIawGaoIg9QNwI0AZF6gHSVgAdFNoDmH4BXp88gOl7FeD92QOYvvcTYDBvAAE5ET4AYpySPgCKOjO9gDHVOcoLGGc5V3sB424XLC9gAvYZ+WAT1Joa0KahxEWWx/0AkKntAJhBQANApjYEcDZhx+kB2JKpdTQA2GEjoGLzEidCN0kVW4BmKCilegGedRttU0RTgBpKhQ544iC+DkADpWIHFJwGwQCY5SFGACwPMU5JUtAoKkDFZicjoI5gqjOTze5HAOeFA2r0hWOAM+tiLCQ3z2LxGedDnVSjnNwqFU3OKDho6KDTltu049SuhYtT3os4Bu0BKjuOrTCFdjPaOERHVinMxip0HsixPPKLYvmKTxS5M0aeVWxBnWzjJqrCOhks4B3nAAwCOgNEBJaXg4vFWBGiJBSUg4sVFSWtmc5UAGyqNdM6CsvKwWWdZR01cfXI3dbVk2BNA/Yp+WCX5TSPxncFiZAXB5ivALIGXwM+ALcuANQ/Ht5+ngHbsI4AoK7eHpKrK5zcmxd18FkhLicdrgGkw00ioOhVJcfA2Eynw6UVnA5j4CYzT4J1fz5cGnDfD38RkM+DLwTc7f/VwLXb/37g/nz4D/yTwEuWPWbmKTN6ynI5K7P5JkNZZtlMLbWe5Vp3m1x35jdfLg6zfL/q8l/fu4XWB7XW+ghgpQHoPTrzwwJtKoo6TGPNHUcZcIA0FlwfLgLTIitfBES3rwROlLQvh8VkkDyJP+PFPZy0niyPmly90XoON6/sLDuhWx8WRwrWS949IlAIGIK1ybs5grXer44U7pKjXdKfCTe9I9zzzew3hQ1VpfX/zmMAAAAASUVORK5CYII=';
    return _initComplete.future;
  }
  static void onPatternLoaded(Event e) {
    var canvas = new CanvasElement();
    canvas.width = 128;
    canvas.height = 128;
    canvas.context2D.drawImage(_pattern, 0, 0);
    List<int> bytes = canvas.context2D.getImageData(0, 0, 128, 128).data;
    // sigils
    for (int i = 0; i < 38; ++i) {
      int xp = i % 8;
      int yp = i ~/ 8;
      int startpos = xp * 64 + yp * 8192;
      List<int> data = [];
      for (int y = 0; y < 16; ++y) for (int x = 0; x < 16; ++x) {
        int cpos = startpos + x * 4 + y * 512;
        if (bytes[cpos] > bytes[cpos + 1]) {
          // red > green
          data.add(bytes[cpos]);
        } else {
          data.add(0);
        }
      }
      datas.add(data);
    }
    // borders
    for (int i = 0; i < 8; ++i) {
      int startpos = i * 64 + 7 * 8192;
      List<int> border = [];
      List<int> mask = [];
      List overlay = [];
      for (int y = 0; y < 16; ++y) for (int x = 0; x < 16; ++x) {
        int cpos = startpos + x * 4 + y * 512;
        if (bytes[cpos] > bytes[cpos + 1]) {
          // red > green
          border.add(bytes[cpos]);
        } else {
          border.add(0);
        }
        if (bytes[cpos + 1] > bytes[cpos + 2]) {
          // green > blue
          mask.add(255 - bytes[cpos + 1]);
        } else {
          mask.add(255);
        }
      }
      borders.add(border);
      masks.add(mask);
    }
    _initComplete.complete('');
  }
  static List<List<int>> datas = [];

  static List<List<int>> borders = [];
  static List<List<int>> masks = [];

  static int aa=1;
  static int bb=1;
  static int tt=0;
  static CanvasElement createFromName(String name) {
    R r = new R(R.utf(name), 2);
    return create(r.S.map((n)=>((n^6)*99 + 218) & 255).toList());
  }

  static CanvasElement canvas = new CanvasElement()..width = 16..height = 16;

  static CanvasElement create(List<int> colors) {
    int pos = 0;
    int borderStyle = colors[pos++] % borders.length;
    List<int> shapeSorted = [];
    shapeSorted.add(colors[pos++] % datas.length);

    int shape2 = colors[pos++] % datas.length;
    if (shape2 == shapeSorted[0]) {
      // second shape should be different
      shape2 = colors[pos++] % datas.length;
    }
    shapeSorted.add(shape2);

    if (colors[pos++] < 4) {
      shapeSorted.add(colors[pos++] % datas.length);
      if (colors[pos++] < 64) {
        shapeSorted.add(colors[pos++] % datas.length);
      }
    }


    var ctx = canvas.context2D;
    List<int> brights = [];
    // drag bg
    int bgCIdx = colors[pos++] % (cCount-6);

    var bgColor = sig_colors[bgCIdx];
    ctx.setFillColorRgb(bgColor[0], bgColor[1], bgColor[2]);
    ctx.fillRect(1, 1, 14, 14);

    List<int> usedColors = [];
    bool validColor(int c) {
      if (usedColors.length > 0 && c == bgCIdx && shapeSorted[0] != shapeSorted[1]) {
        return true;
      }
      if (cdif[c][bgCIdx] < 90.0) return false;
      for (int n in usedColors) {
        if (n == c) return true;
      }
      for (int n in usedColors) {
        if (cdif[c][n] < 90.0) return false;
      }
      return true;
    }
    for (int i = 0; i < shapeSorted.length; ++i) {
      int c = colors[pos++] % cCount;
      while (!validColor(c)) {
        c = colors[pos++] % cCount;
      }

      usedColors.add(c);
      drawShape(ctx, datas[shapeSorted[i]], sig_colors[c]);
    }

    drawBorder(ctx, borderStyle);
    return canvas;
  }
  static CanvasElement shapeCanvas = new CanvasElement()..width = 16..height = 16;
  static ImageData shapeImage = shapeCanvas.context2D.createImageData(16, 16);
  static void drawShape(
      CanvasRenderingContext2D c, List<int> shapeData, List<int> color) {

    int dpos = 0;
    int ipos = 0;
    for (int y = 0; y < 16; ++y) for (int x = 0; x < 16; ++x) {
      if (shapeData[dpos] > 0) {
        shapeImage.data[ipos] = color[0];
        shapeImage.data[ipos + 1] = color[1];
        shapeImage.data[ipos + 2] = color[2];
        shapeImage.data[ipos + 3] = shapeData[dpos];
      } else {
        shapeImage.data[ipos + 3] = 0;
      }
      dpos++;
      ipos += 4;
    }

    shapeCanvas.context2D.putImageData(shapeImage, 0, 0);
    c.drawImage(shapeCanvas, 0, 0);
  }
  static void drawBorder(CanvasRenderingContext2D c, int b) {
    drawShape(c, borders[b], [64, 64, 64]);
    var img = c.getImageData(0, 0, 16, 16);
    List<int> mask = masks[b];
    for (int i = 0; i < 256; ++i) {
      img.data[i * 4 + 3] = mask[i];
    }
    c.putImageData(img, 0, 0);
  }

  static List<int> sortOrder(List<int> input, [int count = 0]) {
    List<Map<String, int>> toSort = [];
    for (int i = 0; i < input.length; ++i) {
      toSort.add({'i': i, 'v': input[i]});
    }
    toSort.sort((var a, var b) => (b['v'] as int).compareTo(a['v']));
    if (count != 0) {
      while (count < toSort.length &&
          toSort[count]['v'] == toSort[count - 1]['v']) {
        count++;
      }
      toSort = toSort.sublist(0, count);
    }
    return toSort.map((var m) => m['i']).toList();
  }
}
