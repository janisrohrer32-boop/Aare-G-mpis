import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../models/cliff_level.dart';

/// Wasseroberfläche liegt bei y = 0.
class Water extends PositionComponent {
  Water(this.level) : super(priority: 5);
  final CliffLevel level;
  double _t = 0;

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    const left = -1200.0, right = 1200.0;
    final path = Path()..moveTo(left, 0);
    for (var x = left; x <= right; x += 20) {
      path.lineTo(x, math.sin(x / 40 + _t * 2) * 4);
    }
    path
      ..lineTo(right, 1600)
      ..lineTo(left, 1600)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = Gradient.linear(const Offset(0, 0), const Offset(0, 500),
            [level.waterColor, const Color(0xFF0D47A1)]),
    );
    // Glanzlinien
    final shine = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final x = -380 + i * 110 + math.sin(_t + i) * 12;
      final y = 18.0 + (i % 3) * 16;
      canvas.drawLine(Offset(x, y), Offset(x + 30, y), shine);
    }
  }
}
