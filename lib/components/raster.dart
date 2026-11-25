import 'dart:math' as math;
import 'dart:ui';

/// Ein einmal vorberechnetes Bild eines Ausschnitts der Spielwelt.
///
/// Tausende Fenster, Asphaltkörner oder weiche Wolken in jedem Frame neu zu
/// zeichnen ist teuer. Ein fertiges Bild zu zeichnen kostet dagegen fast nichts.
/// Breite Ausschnitte werden in Kacheln geteilt, damit auch schwächere
/// Handys sie laden können.
class Raster {
  Raster._(this._tiles);

  final List<(Image, Rect)> _tiles;

  static final Paint _paint = Paint()..filterQuality = FilterQuality.low;

  /// Zeichnet [draw] im Bereich [rect] mit [scale] Bildpunkten pro Einheit.
  ///
  /// [regions] kann danach (also nach [draw]) die Teilbereiche liefern, die
  /// wirklich etwas enthalten. Sie dürfen sich nicht überlappen. Leere Flächen
  /// (z. B. Himmel über der Skyline) müssen dann gar nicht gezeichnet werden.
  static Future<Raster> record(Rect rect, double scale, void Function(Canvas c) draw,
      {int maxTile = 2048, List<Rect> Function()? regions}) async {
    final rec = PictureRecorder();
    draw(Canvas(rec));
    final pic = rec.endRecording();

    final parts = <Rect>[];
    if (regions != null) {
      for (final r in regions()) {
        final clipped = r.intersect(rect);
        if (!clipped.isEmpty) parts.addAll(_split(clipped, maxTile / scale));
      }
    } else {
      parts.addAll(_split(rect, maxTile / scale));
    }

    final tiles = <(Image, Rect)>[];
    for (final part in parts) {
      final w = (part.width * scale).ceil();
      final h = (part.height * scale).ceil();
      final r2 = PictureRecorder();
      final c = Canvas(r2);
      c.scale(scale);
      c.translate(-part.left, -part.top);
      c.drawPicture(pic);
      final tilePic = r2.endRecording();
      final img = await tilePic.toImage(w, h);
      tilePic.dispose();
      tiles.add((img, Rect.fromLTWH(part.left, part.top, w / scale, h / scale)));
    }
    pic.dispose();
    return Raster._(tiles);
  }

  static List<Rect> _split(Rect r, double maxSize) {
    final out = <Rect>[];
    for (var top = r.top; top < r.bottom - 0.01; top += maxSize) {
      for (var left = r.left; left < r.right - 0.01; left += maxSize) {
        out.add(Rect.fromLTRB(left, top, math.min(r.right, left + maxSize), math.min(r.bottom, top + maxSize)));
      }
    }
    return out;
  }

  void draw(Canvas canvas) {
    for (final (img, dst) in _tiles) {
      canvas.drawImageRect(
          img, Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()), dst, _paint);
    }
  }

  /// Das erste (oder einzige) Bild – z. B. als Muster für einen Shader.
  Image get image => _tiles.first.$1;
}
