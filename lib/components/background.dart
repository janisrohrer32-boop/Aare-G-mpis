import 'dart:ui';

import 'package:flame/components.dart';

import '../game/cliff_dive_game.dart';
import '../models/cliff_level.dart';

/// Himmel – fest am Bildschirm (liegt im Backdrop der Kamera).
class Sky extends PositionComponent with HasGameReference<CliffDiveGame> {
  Sky(this.level);
  final CliffLevel level;

  @override
  void render(Canvas canvas) {
    final s = game.camera.viewport.virtualSize;
    final rect = Rect.fromLTWH(0, 0, s.x, s.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          Offset(0, s.y),
          [level.skyTop, level.skyBottom],
        ),
    );
    // Sonne
    canvas.drawCircle(
        Offset(s.x * 0.78, s.y * 0.14), 34, Paint()..color = const Color(0xFFFFF59D));
    canvas.drawCircle(Offset(s.x * 0.78, s.y * 0.14), 46,
        Paint()..color = const Color(0x33FFF59D));
  }
}

/// Berge und Wolken mit Parallax-Effekt (bewegen sich langsamer als die Welt).
class ParallaxLayer extends PositionComponent with HasGameReference<CliffDiveGame> {
  ParallaxLayer({required this.level, required this.factor, required this.kind})
      : super(priority: -10);

  final CliffLevel level;

  /// 0 = bewegt sich mit der Welt, 1 = steht fest am Bildschirm.
  final double factor;
  final String kind;

  @override
  void update(double dt) {
    position = game.camera.viewfinder.position * factor;
  }

  @override
  void render(Canvas canvas) {
    if (kind == 'mountains') {
      final paint = Paint()..color = level.mountainColor;
      final snow = Paint()..color = const Color(0xFFF5F9FC);
      final peaks = <List<double>>[
        [-420, 260],
        [-200, 330],
        [40, 280],
        [260, 350],
        [480, 270],
      ];
      for (final p in peaks) {
        final x = p[0], h = p[1];
        final path = Path()
          ..moveTo(x - 200, 40)
          ..lineTo(x, 40 - h)
          ..lineTo(x + 200, 40)
          ..close();
        canvas.drawPath(path, paint);
        final cap = Path()
          ..moveTo(x - 45, 40 - h + 50)
          ..lineTo(x, 40 - h)
          ..lineTo(x + 45, 40 - h + 50)
          ..quadraticBezierTo(x, 40 - h + 35, x - 45, 40 - h + 50)
          ..close();
        canvas.drawPath(cap, snow);
      }
      // Bäume / Hügel vorne
      final hills = Paint()..color = const Color(0xFF66BB6A);
      canvas.drawOval(const Rect.fromLTWH(-600, 10, 700, 90), hills);
      canvas.drawOval(const Rect.fromLTWH(0, 15, 800, 80), hills);
    } else {
      final cloud = Paint()..color = const Color(0xDDFFFFFF);
      for (final c in const [
        Offset(-150, -420),
        Offset(120, -330),
        Offset(-40, -600),
        Offset(260, -520),
      ]) {
        canvas.drawCircle(c, 22, cloud);
        canvas.drawCircle(c + const Offset(22, -10), 26, cloud);
        canvas.drawCircle(c + const Offset(48, 0), 20, cloud);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(c.dx - 10, c.dy - 4, 74, 22), const Radius.circular(11)),
            cloud);
      }
    }
  }
}
