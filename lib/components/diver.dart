import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../models/character.dart';
import 'woman_painter.dart';

enum DiverPose { stand, crouch, air, tuck, stretch, hero, sprawl }

/// Die Spielfigur. Position = Körpermitte, [angle] = Drehung (0 = aufrecht).
class Diver extends PositionComponent {
  Diver({required this.character, required this.outfit, required this.style})
      : super(size: Vector2(30, 68), anchor: Anchor.center, priority: 10);

  CharacterDef character;
  OutfitDef outfit;
  int style;

  DiverPose pose = DiverPose.stand;
  final Vector2 velocity = Vector2.zero();
  double _time = 0;
  Pose _shown = Pose.stand;
  bool showSparkles = true;

  static Pose _target(DiverPose p) => switch (p) {
        DiverPose.stand => Pose.stand,
        DiverPose.crouch => Pose.crouch,
        DiverPose.air => Pose.air,
        DiverPose.tuck => Pose.tuck,
        DiverPose.stretch => Pose.stretch,
        DiverPose.hero => Pose.hero,
        DiverPose.sprawl => Pose.sprawl,
      };

  /// Haltung sofort setzen (ohne Überblenden).
  void snapPose(DiverPose p) {
    pose = p;
    _shown = _target(p);
  }

  @override
  void update(double dt) {
    _time += dt;
    // weiche Übergänge zwischen Haltungen
    _shown = Pose.lerp(_shown, _target(pose), math.min(1, dt * 14));
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    final grounded = pose == DiverPose.stand ||
        pose == DiverPose.crouch ||
        pose == DiverPose.hero;
    if (style >= 4 && showSparkles) _sparkles(canvas);
    WomanPainter.paint(
      canvas,
      pose: _shown,
      character: character,
      outfit: outfit,
      style: style,
      time: _time,
      grounded: grounded,
      groundY: size.y / 2,
    );
    canvas.restore();
  }

  void _sparkles(Canvas canvas) {
    final p = Paint()..color = const Color(0xCCFFF59D);
    for (var i = 0; i < (style >= 5 ? 5 : 3); i++) {
      final a = _time * 1.5 + i * 2.1;
      final r = 22 + math.sin(_time * 3 + i) * 4;
      final c = Offset(math.cos(a) * r, math.sin(a) * r * 1.3 - 6);
      final s = 1.5 + (math.sin(_time * 6 + i) + 1);
      canvas.drawLine(c.translate(-s, 0), c.translate(s, 0), p..strokeWidth = 1.2);
      canvas.drawLine(c.translate(0, -s), c.translate(0, s), p);
    }
  }
}
