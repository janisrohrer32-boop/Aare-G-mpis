import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../game/cliff_dive_game.dart';
import '../models/level.dart';

/// Himmel mit Abendlicht – fest am Bildschirm.
class Sky extends PositionComponent with HasGameReference<CliffDiveGame> {
  Sky(this.level);
  final JumpLevel level;

  @override
  void render(Canvas canvas) {
    final s = game.camera.viewport.virtualSize;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.x, s.y),
      Paint()
        ..shader = Gradient.linear(Offset.zero, Offset(0, s.y),
            [level.skyTop, const Color(0xFFB9C9DA), level.skyBottom], const [0, 0.55, 1]),
    );
    // tiefstehende Sonne mit Schein
    final sun = Offset(s.x * 0.8, s.y * 0.62);
    canvas.drawCircle(sun, 120, Paint()..color = const Color(0x22FFE0B2));
    canvas.drawCircle(sun, 60, Paint()..color = const Color(0x44FFE0B2));
    canvas.drawCircle(sun, 26, Paint()..color = const Color(0xFFFFF3E0));
  }
}

/// Skyline mit Parallax. [factor] nahe 1 = weit weg (bewegt sich kaum).
class Skyline extends PositionComponent with HasGameReference<CliffDiveGame> {
  Skyline({required this.factor, required this.seed, required this.color, required this.windowColor})
      : super(priority: -10);

  final double factor;
  final int seed;
  final Color color;
  final Color windowColor;
  late final List<Rect> _buildings;
  late final List<List<Rect>> _windows;

  @override
  Future<void> onLoad() async {
    final rnd = math.Random(seed);
    _buildings = [];
    _windows = [];
    var x = -1600.0;
    while (x < 1600) {
      final w = 50.0 + rnd.nextDouble() * 70;
      final h = 120.0 + rnd.nextDouble() * (seed == 1 ? 520 : 300);
      final r = Rect.fromLTWH(x, -h, w, h + 400);
      _buildings.add(r);
      final wins = <Rect>[];
      for (var wy = r.top + 12; wy < 0; wy += 18) {
        for (var wx = r.left + 7; wx < r.right - 10; wx += 13) {
          if (rnd.nextDouble() < 0.25) wins.add(Rect.fromLTWH(wx, wy, 6, 8));
        }
      }
      _windows.add(wins);
      x += w + 10 + rnd.nextDouble() * 60;
    }
  }

  @override
  void update(double dt) {
    position = game.camera.viewfinder.position * factor;
  }

  @override
  void render(Canvas canvas) {
    final p = Paint()..color = color;
    final wp = Paint()..color = windowColor;
    for (var i = 0; i < _buildings.length; i++) {
      canvas.drawRect(_buildings[i], p);
      for (final w in _windows[i]) {
        canvas.drawRect(w, wp);
      }
    }
  }
}

/// Das Hochhaus mit Balkonen. Die Balkonkante liegt bei [edgeX], der
/// Balkonboden bei [topY]. Der Boden (Asphalt) liegt bei y = 0.
class Tower extends PositionComponent {
  Tower({required this.edgeX, required this.topY, required this.floorHeight})
      : super(priority: 0);

  final double edgeX;
  final double topY;
  final double floorHeight;

  static const double balconyDepth = 46;

  double get wallX => edgeX - balconyDepth;

  @override
  void render(Canvas canvas) {
    const left = -1400.0;
    final top = topY - floorHeight * 6;
    // Fassade
    canvas.drawRect(
      Rect.fromLTRB(left, top, wallX, 0),
      Paint()
        ..shader = Gradient.linear(Offset(wallX - 200, 0), Offset(wallX, 0),
            const [Color(0xFF8A96A3), Color(0xFFB4BEC8)]),
    );
    // Fenster-Raster
    final glass = Paint()
      ..shader = Gradient.linear(Offset(0, top), const Offset(0, 0),
          const [Color(0xFF5C7A99), Color(0xFF8FB0CC)]);
    final frame = Paint()..color = const Color(0xFF6B7682);
    for (var y = top; y < -10; y += floorHeight) {
      canvas.drawRect(Rect.fromLTRB(left, y + floorHeight - 4, wallX, y + floorHeight), frame);
      for (var x = wallX - 18; x > left; x -= 44) {
        final r = Rect.fromLTWH(x - 30, y + 14, 30, floorHeight - 26);
        canvas.drawRect(r, glass);
        canvas.drawLine(Offset(r.left + 6, r.top + 4), Offset(r.left + 12, r.top + 4),
            Paint()
              ..color = const Color(0x55FFFFFF)
              ..strokeWidth = 2);
      }
    }
    // Balkone (jedes Stockwerk)
    for (var y = topY; y < -floorHeight * 0.5; y += floorHeight) {
      _balcony(canvas, y, y == topY);
    }
    // Erdgeschoss: Eingang
    canvas.drawRect(Rect.fromLTRB(wallX - 90, -70, wallX - 20, 0),
        Paint()..color = const Color(0xFF37474F));
    canvas.drawRect(Rect.fromLTRB(wallX - 84, -64, wallX - 26, 0),
        Paint()..color = const Color(0xFF90A4AE));
  }

  void _balcony(Canvas canvas, double y, bool isJumpBalcony) {
    final depth = isJumpBalcony ? balconyDepth : balconyDepth - 8;
    // Bodenplatte
    canvas.drawRect(Rect.fromLTWH(wallX, y, depth, 7), Paint()..color = const Color(0xFFD5D9DD));
    canvas.drawRect(Rect.fromLTWH(wallX, y + 7, depth, 3), Paint()..color = const Color(0xFF9EA6AE));
    if (isJumpBalcony) return; // beim Absprung-Balkon ist das Geländer offen
    // Glasgeländer
    canvas.drawRect(Rect.fromLTWH(wallX, y - 28, depth, 28), Paint()..color = const Color(0x5590CAF9));
    canvas.drawRect(Rect.fromLTWH(wallX, y - 30, depth, 3), Paint()..color = const Color(0xFF78909C));
  }
}

/// Strasse mit Gehweg. Oberkante bei y = 0.
class Street extends PositionComponent {
  Street({required this.curbX}) : super(priority: 5);

  final double curbX;

  @override
  void render(Canvas canvas) {
    // Gehweg
    canvas.drawRect(Rect.fromLTRB(-1500, 0, curbX, 600), Paint()..color = const Color(0xFFA7A39B));
    for (var x = -1500.0; x < curbX; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, 18),
          Paint()
            ..color = const Color(0xFF8E8A83)
            ..strokeWidth = 1);
    }
    // Bordstein
    canvas.drawRect(Rect.fromLTWH(curbX, 0, 8, 600), Paint()..color = const Color(0xFFC9C5BD));
    // Asphalt
    canvas.drawRect(
      Rect.fromLTRB(curbX + 8, 4, 1600, 600),
      Paint()
        ..shader = Gradient.linear(const Offset(0, 0), const Offset(0, 120),
            const [Color(0xFF4A4D52), Color(0xFF2E3035)]),
    );
    // Mittellinie
    final line = Paint()..color = const Color(0xFFF5F5F5);
    for (var x = curbX + 40; x < 1600; x += 70) {
      canvas.drawRect(Rect.fromLTWH(x, 40, 36, 5), line);
    }
    // Strassenlaterne
    final pole = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 4;
    final px = curbX + 250;
    canvas.drawLine(Offset(px, 0), Offset(px, -170), pole);
    canvas.drawLine(Offset(px, -170), Offset(px - 34, -176), pole);
    canvas.drawCircle(Offset(px - 34, -172), 6, Paint()..color = const Color(0xFFFFF59D));
  }
}

/// Risse im Asphalt nach einer Superhelden-Landung.
class Cracks extends PositionComponent {
  Cracks({required Vector2 position, required this.big})
      : super(position: position, priority: 6);
  final bool big;
  double _t = 0;

  @override
  void update(double dt) => _t = math.min(1, _t + dt * 5);

  @override
  void render(Canvas canvas) {
    final rnd = math.Random(7);
    final p = Paint()
      ..color = const Color(0xFF151618)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final n = big ? 9 : 5;
    for (var i = 0; i < n; i++) {
      final ang = -math.pi + (i + 0.5) * math.pi / n * 2;
      var pt = Offset.zero;
      final len = (big ? 46.0 : 24.0) * _t;
      for (var s = 0; s < 3; s++) {
        final a = ang + (rnd.nextDouble() - 0.5) * 0.8;
        final next = pt + Offset(math.cos(a) * len / 3, (math.sin(a).abs() * 0.25) * len / 3 + 1);
        canvas.drawLine(pt, next, p);
        pt = next;
      }
    }
  }
}

/// Kreisende Sterne über dem Kopf nach einer Bruchlandung (Cartoon).
class DizzyStars extends PositionComponent {
  DizzyStars({required Vector2 position}) : super(position: position, priority: 30);
  double _t = 0;

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      final a = _t * 4 + i * 2 * math.pi / 3;
      final c = Offset(math.cos(a) * 16, math.sin(a) * 5);
      _star(canvas, c, 4.5);
    }
  }

  void _star(Canvas canvas, Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rr = i.isEven ? r : r * 0.45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = const Color(0xFFFFD600));
  }
}
