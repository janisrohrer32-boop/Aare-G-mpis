import 'dart:io';
import 'dart:ui' as ui;

import 'package:cliff_dive/components/woman_painter.dart';
import 'package:cliff_dive/models/character.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendert eine Übersicht aller Figuren und Outfits als PNG
/// (nur wenn PREVIEW_OUT gesetzt ist).
void main() {
  final out = Platform.environment['PREVIEW_OUT'];
  test('render preview', () async {
    if (out == null) return;
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    const w = 1400.0, h = 700.0;
    c.drawRect(const ui.Rect.fromLTWH(0, 0, w, h), ui.Paint()..color = const ui.Color(0xFFDDE6EE));
    final chars = Catalog.characters;
    for (var i = 0; i < chars.length; i++) {
      c.save();
      c.translate(55.0 + i * 105, 140);
      c.scale(2.6);
      WomanPainter.paint(c, pose: Pose.stand, character: chars[i], outfit: Catalog.outfits[i % Catalog.outfits.length], grounded: true);
      c.restore();
    }
    final outs = Catalog.outfits;
    for (var i = 0; i < outs.length; i++) {
      c.save();
      c.translate(55.0 + i * 105, 380);
      c.scale(2.6);
      WomanPainter.paint(c, pose: Pose.stand, character: chars[i % 6], outfit: outs[i], grounded: true);
      c.restore();
    }
    for (var i = 0; i < 6; i++) {
      c.save();
      c.translate(80.0 + i * 200, 600);
      c.scale(2.6);
      WomanPainter.paint(c, pose: Pose.walk(i * 0.12), character: chars[6 + i], outfit: outs[0], grounded: true);
      c.restore();
    }
    final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File('$out/preview.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
