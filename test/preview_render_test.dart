import 'dart:io';
import 'dart:ui' as ui;

import 'package:cliff_dive/components/woman_painter.dart';
import 'package:cliff_dive/models/character.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final out = Platform.environment['PREVIEW_OUT'];
  test('render poses', () async {
    if (out == null) return;
    final poses = [Pose.stand, Pose.crouch, Pose.air, Pose.tuck, Pose.stretch, Pose.hero, Pose.sprawl];
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    c.drawRect(const ui.Rect.fromLTWH(0, 0, 1400, 900), ui.Paint()..color = const ui.Color(0xFFDDE6EE));
    for (var row = 0; row < 3; row++) {
      for (var i = 0; i < poses.length; i++) {
        c.save();
        c.translate(100.0 + i * 190, 150.0 + row * 290);
        c.scale(3.2);
        WomanPainter.paint(c,
            pose: poses[i],
            character: Catalog.characters[row + (row == 2 ? 2 : 0)],
            outfit: Catalog.outfits[[0, 5, 1][row]],
            style: [3, 5, 0][row],
            grounded: i == 5 || i == 0);
        c.restore();
      }
    }
    final img = await rec.endRecording().toImage(1400, 900);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File('$out/poses.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
