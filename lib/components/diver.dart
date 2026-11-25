import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../models/trick.dart';

enum DiverPose { stand, crouch, tuck, stretch, normal }

/// Der Spielcharakter. Wird als einfache Cartoon-Figur gezeichnet
/// (Platzhalter – später durch Sprites austauschbar).
///
/// Position = Körpermitte, [angle] = Drehung (0 = aufrecht).
class Diver extends PositionComponent {
  Diver() : super(size: Vector2(26, 60), anchor: Anchor.center, priority: 10);

  DiverPose pose = DiverPose.stand;
  final Vector2 velocity = Vector2.zero();

  Trick? currentTrick;
  double _trickRemaining = 0; // verbleibende Drehung (Betrag, Radiant)

  bool get trickInProgress => currentTrick != null;

  /// Fortschritt des aktuellen Tricks 0..1.
  double get trickProgress => currentTrick == null
      ? 0
      : 1 - _trickRemaining / currentTrick!.rotation.abs();

  // Farben – im Shop später austauschbar.
  Color skin = const Color(0xFFFFCC99);
  Color shorts = const Color(0xFFFF5252);
  Color hair = const Color(0xFF5D4037);

  void startTrick(Trick trick) {
    currentTrick = trick;
    _trickRemaining = trick.rotation.abs();
    pose = DiverPose.tuck;
  }

  /// Dreht weiter. Gibt den Trick zurück, wenn er in diesem Frame fertig wurde.
  Trick? updateTrick(double dt) {
    final t = currentTrick;
    if (t == null) return null;
    final speed = t.rotation.abs() / t.duration;
    final step = math.min(speed * dt, _trickRemaining);
    angle += step * t.rotation.sign;
    _trickRemaining -= step;
    if (_trickRemaining <= 1e-6) {
      currentTrick = null;
      pose = DiverPose.normal;
      return t;
    }
    return null;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    final cx = w / 2;
    final skinP = Paint()..color = skin;
    final limb = Paint()
      ..color = skin
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final outline = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (pose) {
      case DiverPose.tuck:
        // Zusammengerollt (Hocke): kompakter Ball
        canvas.drawLine(Offset(cx, h * 0.45), Offset(cx + 10, h * 0.62), limb);
        canvas.drawLine(Offset(cx + 10, h * 0.62), Offset(cx - 2, h * 0.72), limb);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 2, h * 0.5), width: 20, height: 24),
            skinP);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 3, h * 0.6), width: 20, height: 12),
            Paint()..color = shorts);
        canvas.drawLine(Offset(cx, h * 0.46), Offset(cx + 9, h * 0.58), limb);
        _head(canvas, Offset(cx + 4, h * 0.3));
        return;
      case DiverPose.stretch:
        // Gestreckt, Arme über dem Kopf – sauberes Eintauchen
        canvas.drawLine(Offset(cx, h * 0.3), Offset(cx - 2, -h * 0.02), limb);
        canvas.drawLine(Offset(cx, h * 0.3), Offset(cx + 2, -h * 0.02), limb);
        _body(canvas, cx, h, outline);
        canvas.drawLine(Offset(cx - 2, h * 0.68), Offset(cx - 1, h * 1.0), limb);
        canvas.drawLine(Offset(cx + 2, h * 0.68), Offset(cx + 1, h * 1.0), limb);
        _head(canvas, Offset(cx, h * 0.16));
        return;
      case DiverPose.crouch:
        canvas.drawLine(Offset(cx - 3, h * 0.72), Offset(cx + 8, h * 0.85), limb);
        canvas.drawLine(Offset(cx + 8, h * 0.85), Offset(cx - 2, h * 1.0), limb);
        _body(canvas, cx, h, outline, dy: h * 0.1);
        canvas.drawLine(Offset(cx, h * 0.45), Offset(cx - 12, h * 0.68), limb);
        _head(canvas, Offset(cx + 2, h * 0.27));
        return;
      case DiverPose.stand:
      case DiverPose.normal:
        canvas.drawLine(Offset(cx - 3, h * 0.68), Offset(cx - 5, h * 1.0), limb);
        canvas.drawLine(Offset(cx + 3, h * 0.68), Offset(cx + 5, h * 1.0), limb);
        _body(canvas, cx, h, outline);
        final armEnd = pose == DiverPose.normal
            ? Offset(cx + 13, h * 0.2)
            : Offset(cx + 4, h * 0.62);
        canvas.drawLine(Offset(cx, h * 0.34), armEnd, limb);
        _head(canvas, Offset(cx, h * 0.16));
    }
  }

  void _body(Canvas canvas, double cx, double h, Paint outline, {double dy = 0}) {
    final torso = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 8, h * 0.28 + dy, 16, h * 0.3), const Radius.circular(8));
    canvas.drawRRect(torso, Paint()..color = skin);
    canvas.drawRRect(torso, outline);
    final pants = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 8.5, h * 0.55 + dy * 0.6, 17, h * 0.15), const Radius.circular(5));
    canvas.drawRRect(pants, Paint()..color = shorts);
  }

  void _head(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 9, Paint()..color = skin);
    canvas.drawArc(Rect.fromCircle(center: c, radius: 9.5), math.pi, math.pi, true,
        Paint()..color = hair);
    // Auge (blickt nach rechts)
    canvas.drawCircle(c + const Offset(4, 1), 1.8, Paint()..color = const Color(0xFF222222));
  }
}
