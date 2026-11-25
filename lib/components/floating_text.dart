import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle, Shadow;

/// Text, der hochschwebt, kurz größer wird und ausblendet
/// (für Trick-Namen und Punkte).
class FloatingText extends PositionComponent {
  FloatingText(this.text,
      {required Vector2 position,
      this.color = const Color(0xFFFFFFFF),
      this.fontSize = 28,
      this.lifetime = 1.4})
      : super(position: position, anchor: Anchor.center, priority: 100);

  final String text;
  final Color color;
  final double fontSize;
  final double lifetime;
  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
    position.y -= 40 * dt;
    if (_t >= lifetime) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final p = (_t / lifetime).clamp(0.0, 1.0);
    final pop = p < 0.15 ? 0.6 + p / 0.15 * 0.5 : (p < 0.25 ? 1.1 - (p - 0.15) : 1.0);
    final alpha = p < 0.7 ? 1.0 : 1 - (p - 0.7) / 0.3;
    final tp = TextPaint(
      style: TextStyle(
        fontSize: fontSize * pop,
        fontWeight: FontWeight.w900,
        color: color.withValues(alpha: alpha),
        shadows: [
          Shadow(
              color: const Color(0xFF000000).withValues(alpha: 0.45 * alpha),
              offset: const Offset(2, 2),
              blurRadius: 3)
        ],
      ),
    );
    tp.render(canvas, text, Vector2.zero(), anchor: Anchor.center);
  }
}
