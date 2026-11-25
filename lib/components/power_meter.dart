import 'dart:ui';

import 'package:flame/components.dart';

/// Balken für die Sprungkraft, wird beim Halten aufgeladen.
class PowerMeter extends PositionComponent {
  PowerMeter() : super(size: Vector2(26, 220), priority: 50);

  double value = 0;
  bool visible = true;

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    final r = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(13));
    canvas.drawRRect(r, Paint()..color = const Color(0x66000000));
    final fillH = (size.y - 8) * value;
    final fill = RRect.fromRectAndRadius(
        Rect.fromLTWH(4, size.y - 4 - fillH, size.x - 8, fillH), const Radius.circular(9));
    canvas.drawRRect(
      fill,
      Paint()
        ..shader = Gradient.linear(Offset(0, size.y), Offset.zero,
            const [Color(0xFF66BB6A), Color(0xFFFFEE58), Color(0xFFFF7043)], const [0, 0.5, 1]),
    );
    canvas.drawRRect(
        r,
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
  }
}
