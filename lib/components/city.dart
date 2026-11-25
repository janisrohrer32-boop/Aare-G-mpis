import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show HSVColor;

import '../game/cliff_dive_game.dart';
import '../models/character.dart';
import '../models/level.dart';
import 'woman_painter.dart';

/// Himmel mit Abendlicht – fest am Bildschirm.
class Sky extends PositionComponent with HasGameReference<CliffDiveGame> {
  Sky(this.level);
  final JumpLevel level;

  @override
  void render(Canvas canvas) {
    final s = game.camera.viewport.virtualSize;
    // Je höher die Kamera, desto tiefer blau der Himmel.
    final h = (-game.camera.viewfinder.position.y / 4000).clamp(0.0, 1.0);
    final top = Color.lerp(level.skyTop, const Color(0xFF1F3E6B), h)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.x, s.y),
      Paint()
        ..shader = Gradient.linear(Offset.zero, Offset(0, s.y),
            [top, const Color(0xFF9DB7D3), level.skyBottom], const [0, 0.6, 1]),
    );
    final sun = Offset(s.x * 0.82, s.y * (0.66 + h * 0.3));
    canvas.drawCircle(sun, 140,
        Paint()
          ..color = const Color(0x40FFD7A8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60));
    canvas.drawCircle(sun, 40,
        Paint()
          ..color = const Color(0x99FFE9CC)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    canvas.drawCircle(sun, 18, Paint()..color = const Color(0xFFFFF6E8));
  }
}

/// Weiche Wolken weit hinten.
class Clouds extends PositionComponent with HasGameReference<CliffDiveGame> {
  Clouds() : super(priority: -20);
  Picture? _pic;

  @override
  void update(double dt) => position = game.camera.viewfinder.position * 0.96;

  @override
  void render(Canvas canvas) {
    _pic ??= _record();
    canvas.drawPicture(_pic!);
  }

  Picture _record() {
    final rec = PictureRecorder();
    final c = Canvas(rec);
    final rnd = math.Random(5);
    for (var i = 0; i < 22; i++) {
      final cx = -900 + rnd.nextDouble() * 1800;
      final cy = -1400 + rnd.nextDouble() * 1200;
      final w = 120 + rnd.nextDouble() * 220;
      for (var k = 0; k < 5; k++) {
        c.drawOval(
          Rect.fromCenter(
              center: Offset(cx + (k - 2) * w * 0.18, cy + rnd.nextDouble() * 14 - (k % 2) * 10),
              width: w * 0.5,
              height: w * 0.22),
          Paint()
            ..color = const Color(0x66FFFFFF)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
        );
      }
      c.drawOval(Rect.fromCenter(center: Offset(cx, cy + 10), width: w, height: w * 0.12),
          Paint()
            ..color = const Color(0x33E8C9B0)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }
    return rec.endRecording();
  }
}

/// Dunst über dem Horizont (Luftperspektive).
class Haze extends PositionComponent with HasGameReference<CliffDiveGame> {
  Haze({required this.factor}) : super(priority: -12);
  final double factor;

  @override
  void update(double dt) => position = game.camera.viewfinder.position * factor;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -500, 2000, 100),
      Paint()
        ..shader = Gradient.linear(const Offset(0, -500), const Offset(0, 100),
            const [Color(0x00E9D6C2), Color(0xAAE9D6C2)]),
    );
  }
}

/// Skyline mit Parallax. Wird einmal gezeichnet und dann als Bild wiederverwendet.
class Skyline extends PositionComponent with HasGameReference<CliffDiveGame> {
  Skyline({required this.factor, required this.seed, required this.layer})
      : super(priority: layer == 0 ? -15 : -10);

  final double factor;
  final int seed;
  final int layer;
  Picture? _pic;

  @override
  void update(double dt) => position = game.camera.viewfinder.position * factor;

  @override
  void render(Canvas canvas) {
    _pic ??= _record();
    canvas.drawPicture(_pic!);
  }

  Picture _record() {
    final rec = PictureRecorder();
    final c = Canvas(rec);
    final rnd = math.Random(seed);
    final far = layer == 0;
    final base = far ? const Color(0xFFA3B4C9) : const Color(0xFF6C7D93);
    final lit = far ? const Color(0x22FFFFFF) : const Color(0x66FFE2A8);
    var x = -1800.0;
    while (x < 3200) {
      final w = 50.0 + rnd.nextDouble() * (far ? 90 : 80);
      final h = (far ? 180.0 : 110.0) + rnd.nextDouble() * (far ? 560 : 330);
      final r = Rect.fromLTWH(x, -h, w, h + 400);
      // Gebäude mit Licht von rechts (Sonne)
      c.drawRect(
        r,
        Paint()
          ..shader = Gradient.linear(Offset(r.left, 0), Offset(r.right, 0), [
            Color.lerp(base, const Color(0xFF000000), 0.12)!,
            Color.lerp(base, const Color(0xFFFFE0C0), 0.18)!,
          ]),
      );
      // Dachaufbauten
      if (rnd.nextDouble() < 0.6) {
        final rw = w * (0.3 + rnd.nextDouble() * 0.3);
        c.drawRect(Rect.fromLTWH(r.left + w * 0.2, -h - 12, rw, 12), Paint()..color = base);
      }
      if (rnd.nextDouble() < 0.3) {
        c.drawLine(Offset(r.center.dx, -h), Offset(r.center.dx, -h - 40 - rnd.nextDouble() * 50),
            Paint()
              ..color = base
              ..strokeWidth = 2);
      }
      // Fenster
      final wp = Paint()..color = lit;
      final glass = Paint()..color = Color.lerp(base, const Color(0xFF9EC3E6), 0.25)!;
      for (var wy = r.top + 10; wy < -4; wy += far ? 12 : 16) {
        for (var wx = r.left + 5; wx < r.right - 8; wx += far ? 9 : 12) {
          final v = rnd.nextDouble();
          final win = Rect.fromLTWH(wx, wy, far ? 4 : 6, far ? 6 : 8);
          if (v < 0.12) {
            c.drawRect(win, wp);
          } else if (v < 0.7) {
            c.drawRect(win, glass);
          }
        }
      }
      x += w + 6 + rnd.nextDouble() * 40;
    }
    return rec.endRecording();
  }
}

/// Das Hochhaus: Glasfassade mit Balkonen in jedem Stock.
/// Der Absprung-Balkon liegt bei [jumpFloorY], der Boden bei y = 0.
class Tower extends PositionComponent with HasGameReference<CliffDiveGame> {
  Tower({required this.edgeX, required this.floorHeight}) : super(priority: 0);

  final double edgeX;
  final double floorHeight;
  double jumpFloorY = -960;

  static const double balconyDepth = 46;
  static const double left = -700;
  double get wallX => edgeX - balconyDepth;

  Picture? _floor;
  Picture? _lobby;

  @override
  void render(Canvas canvas) {
    _floor ??= _recordFloor();
    _lobby ??= _recordLobby();
    final view = game.camera.visibleWorldRect.inflate(60);
    final topFloor = jumpFloorY - floorHeight * 8;
    // Stockwerke (nur die sichtbaren)
    for (var y = -floorHeight; y >= topFloor; y -= floorHeight) {
      if (y > view.bottom || y + floorHeight < view.top) continue;
      canvas.save();
      canvas.translate(0, y);
      canvas.drawPicture(_floor!);
      canvas.restore();
      if (y + floorHeight <= jumpFloorY + 1 && y + floorHeight > topFloor) {
        _balcony(canvas, y + floorHeight, (y + floorHeight - jumpFloorY).abs() < 1);
      }
    }
    // Dachkante
    canvas.drawRect(Rect.fromLTRB(left, topFloor - 14, wallX + 6, topFloor),
        Paint()..color = const Color(0xFF59626C));
    canvas.drawPicture(_lobby!);
  }

  Picture _recordFloor() {
    final rec = PictureRecorder();
    final c = Canvas(rec);
    final h = floorHeight;
    const spandrel = 22.0;
    // Brüstungsband (Naturstein/Beton) unten im Stockwerk
    c.drawRect(
        Rect.fromLTRB(left, h - spandrel, wallX, h),
        Paint()
          ..shader = Gradient.linear(Offset(0, h - spandrel), Offset(0, h),
              const [Color(0xFFCFC8BC), Color(0xFFA39B8F)]));
    c.drawRect(Rect.fromLTRB(left, h - spandrel, wallX, h - spandrel + 2),
        Paint()..color = const Color(0xFF7D766C));
    // Fensterband: dunkles, spiegelndes Glas
    c.drawRect(
      Rect.fromLTRB(left, 0, wallX, h - spandrel),
      Paint()
        ..shader = Gradient.linear(Offset.zero, Offset(0, h - spandrel), const [
          Color(0xFF243447),
          Color(0xFF3E5A78),
          Color(0xFF6D8DAB),
        ], const [0, 0.55, 1]),
    );
    // Spiegelung der Abendsonne
    final refl = Path()
      ..moveTo(wallX - 160, 0)
      ..lineTo(wallX - 110, 0)
      ..lineTo(wallX - 150, h - spandrel)
      ..lineTo(wallX - 200, h - spandrel)
      ..close();
    c.drawPath(refl, Paint()..color = const Color(0x33FFD9B0));
    // Innenräume: manche Fenster mit warmem Licht oder Vorhängen
    final rnd = math.Random(3);
    for (var x = wallX - 6; x > left; x -= 40) {
      final v = rnd.nextDouble();
      if (v < 0.25) {
        c.drawRect(Rect.fromLTWH(x - 36, 6, 34, h - spandrel - 8), Paint()..color = const Color(0x55FFD79A));
      } else if (v < 0.45) {
        c.drawRect(Rect.fromLTWH(x - 36, 4, 34, (h - spandrel) * 0.45),
            Paint()..color = const Color(0x44D9D2C5));
      }
    }
    // Fensterpfosten (Aluminium)
    final mull = Paint()..color = const Color(0xFF1E262E);
    final mullLight = Paint()..color = const Color(0x55FFFFFF);
    for (var x = wallX - 2; x > left; x -= 40) {
      c.drawRect(Rect.fromLTWH(x - 2, 0, 4, h - spandrel), mull);
      c.drawRect(Rect.fromLTWH(x + 1, 0, 1, h - spandrel), mullLight);
    }
    // Gebäudekante mit Lichtkante
    c.drawRect(Rect.fromLTWH(wallX - 8, 0, 8, h), Paint()..color = const Color(0xFFBFB8AC));
    c.drawRect(Rect.fromLTWH(wallX - 2, 0, 2, h), Paint()..color = const Color(0xFFF1E6D6));
    return rec.endRecording();
  }

  Picture _recordLobby() {
    final rec = PictureRecorder();
    final c = Canvas(rec);
    c.drawRect(Rect.fromLTRB(left, -floorHeight, wallX, 0), Paint()..color = const Color(0xFF3B434B));
    c.drawRect(Rect.fromLTRB(wallX - 110, -86, wallX - 12, 0),
        Paint()
          ..shader = Gradient.linear(const Offset(0, -86), Offset.zero,
              const [Color(0xFFFFE3B0), Color(0xFFB9925E)]));
    final frame = Paint()..color = const Color(0xFF22282E);
    for (var x = wallX - 110; x <= wallX - 12; x += 24.5) {
      c.drawRect(Rect.fromLTWH(x, -86, 3, 86), frame);
    }
    c.drawRect(Rect.fromLTRB(wallX - 126, -100, wallX + 4, -88), Paint()..color = const Color(0xFF22282E));
    return rec.endRecording();
  }

  void _balcony(Canvas canvas, double y, bool isJumpBalcony) {
    final depth = isJumpBalcony ? balconyDepth : balconyDepth - 8;
    // Schatten unter der Platte
    canvas.drawRect(Rect.fromLTWH(wallX - 4, y + 8, depth + 4, 14),
        Paint()
          ..color = const Color(0x55000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // Bodenplatte
    canvas.drawRect(
        Rect.fromLTWH(wallX, y, depth, 8),
        Paint()
          ..shader = Gradient.linear(Offset(0, y), Offset(0, y + 8),
              const [Color(0xFFE6E8EA), Color(0xFF9EA6AE)]));
    if (isJumpBalcony) {
      // Geländer nur am Haus, vorne offen (Sprungstelle)
      canvas.drawRect(Rect.fromLTWH(wallX, y - 30, 3, 30), Paint()..color = const Color(0xFF78858F));
      return;
    }
    // Glasgeländer mit Metallhandlauf
    canvas.drawRect(Rect.fromLTWH(wallX, y - 28, depth, 28),
        Paint()
          ..shader = Gradient.linear(Offset(wallX, y - 28), Offset(wallX + depth, y),
              const [Color(0x5590CAF9), Color(0x33FFFFFF)]));
    canvas.drawRect(Rect.fromLTWH(wallX, y - 31, depth, 3), Paint()..color = const Color(0xFFB0BEC5));
    canvas.drawRect(Rect.fromLTWH(wallX + depth - 2, y - 31, 2, 31), Paint()..color = const Color(0xFF90A4AE));
  }
}

/// Strasse mit Gehweg, Laterne, Baum und geparktem Auto. Oberkante bei y = 0.
class Street extends PositionComponent {
  Street({required this.curbX}) : super(priority: 5);

  final double curbX;
  Picture? _pic;

  @override
  void render(Canvas canvas) {
    _pic ??= _record();
    canvas.drawPicture(_pic!);
  }

  Picture _record() {
    final rec = PictureRecorder();
    final c = Canvas(rec);
    final rnd = math.Random(11);
    // Gehweg mit Platten
    c.drawRect(Rect.fromLTRB(-1500, 0, curbX, 600),
        Paint()
          ..shader = Gradient.linear(Offset.zero, const Offset(0, 40),
              const [Color(0xFFB9B3A8), Color(0xFF8D877D)]));
    for (var x = -1500.0; x < curbX; x += 34) {
      c.drawLine(Offset(x, 0), Offset(x - 6, 30), Paint()
        ..color = const Color(0x55000000)
        ..strokeWidth = 1);
    }
    // Bordstein
    c.drawRect(Rect.fromLTWH(curbX, -2, 9, 602), Paint()..color = const Color(0xFFD3CEC4));
    c.drawRect(Rect.fromLTWH(curbX + 9, 0, 6, 600), Paint()..color = const Color(0x66000000));
    // Asphalt mit Körnung
    c.drawRect(
      Rect.fromLTRB(curbX + 9, 3, 5000, 600),
      Paint()
        ..shader = Gradient.linear(const Offset(0, 0), const Offset(0, 140),
            const [Color(0xFF55585E), Color(0xFF2B2D31)]),
    );
    final speck = Paint();
    for (var i = 0; i < 6000; i++) {
      final x = curbX + 12 + rnd.nextDouble() * 4900;
      final y = 4 + rnd.nextDouble() * 140;
      speck.color = rnd.nextBool() ? const Color(0x22FFFFFF) : const Color(0x33000000);
      c.drawRect(Rect.fromLTWH(x, y, 1.4, 1.4), speck);
    }
    // Flicken und Gully
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(curbX + 420, 6, 90, 16), const Radius.circular(6)),
        Paint()..color = const Color(0x22000000));
    c.drawOval(Rect.fromLTWH(curbX + 160, 10, 36, 8), Paint()..color = const Color(0xFF2A2A2A));
    // Fahrbahnmarkierung
    final line = Paint()..color = const Color(0xDDEDEDED);
    for (var x = curbX + 40; x < 5000; x += 80) {
      c.drawRect(Rect.fromLTWH(x, 46, 42, 4), line);
    }
    // Baum auf dem Gehweg
    _tree(c, curbX - 70);
    // Laterne
    final px = curbX + 330;
    final pole = Paint()
      ..color = const Color(0xFF2F3A40)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(px, 2), Offset(px, -190), pole);
    c.drawLine(Offset(px, -190), Offset(px - 40, -196), pole);
    c.drawCircle(Offset(px - 40, -190), 18,
        Paint()
          ..color = const Color(0x55FFE9A8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px - 50, -195, 18, 6), const Radius.circular(3)),
        Paint()..color = const Color(0xFFFFF3C4));
    // geparktes Auto
    _car(c, curbX + 560);
    return rec.endRecording();
  }

  void _tree(Canvas c, double x) {
    c.drawOval(Rect.fromCenter(center: Offset(x, 2), width: 70, height: 10),
        Paint()
          ..color = const Color(0x44000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    final trunk = Path()
      ..moveTo(x - 5, 0)
      ..lineTo(x - 3, -90)
      ..lineTo(x + 3, -90)
      ..lineTo(x + 5, 0)
      ..close();
    c.drawPath(trunk, Paint()..color = const Color(0xFF4E3B2C));
    final rnd = math.Random(2);
    for (var i = 0; i < 26; i++) {
      final o = Offset(x + (rnd.nextDouble() - 0.5) * 80, -120 + (rnd.nextDouble() - 0.5) * 70);
      final shade = Color.lerp(const Color(0xFF2E5B2E), const Color(0xFF7FAF5A), rnd.nextDouble())!;
      c.drawCircle(o, 12 + rnd.nextDouble() * 10,
          Paint()
            ..color = shade
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
    }
  }

  void _car(Canvas c, double x) {
    c.drawOval(Rect.fromCenter(center: Offset(x + 60, 30), width: 140, height: 12),
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    final body = Path()
      ..moveTo(x, 18)
      ..lineTo(x + 2, 2)
      ..quadraticBezierTo(x + 10, -6, x + 28, -8)
      ..lineTo(x + 40, -26)
      ..quadraticBezierTo(x + 60, -32, x + 86, -26)
      ..lineTo(x + 102, -8)
      ..quadraticBezierTo(x + 120, -6, x + 124, 4)
      ..lineTo(x + 124, 18)
      ..close();
    c.drawPath(body,
        Paint()
          ..shader = Gradient.linear(Offset(0, -30), const Offset(0, 20),
              const [Color(0xFFD84343), Color(0xFF8E1F1F)]));
    final glass = Path()
      ..moveTo(x + 34, -9)
      ..lineTo(x + 44, -23)
      ..quadraticBezierTo(x + 60, -28, x + 82, -23)
      ..lineTo(x + 96, -9)
      ..close();
    c.drawPath(glass,
        Paint()
          ..shader = Gradient.linear(Offset(x + 40, -25), Offset(x + 90, -8),
              const [Color(0xFF9FC3E0), Color(0xFF2E3B4A)]));
    c.drawLine(Offset(x + 64, -26), Offset(x + 64, -9), Paint()
      ..color = const Color(0xFF8E1F1F)
      ..strokeWidth = 3);
    c.drawLine(Offset(x + 8, -2), Offset(x + 118, -2), Paint()
      ..color = const Color(0x55FFFFFF)
      ..strokeWidth = 1.5);
    for (final wx in [x + 28, x + 98]) {
      c.drawCircle(Offset(wx, 18), 12, Paint()..color = const Color(0xFF1C1C1C));
      c.drawCircle(Offset(wx, 18), 6, Paint()..color = const Color(0xFF9E9E9E));
    }
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 116, -2, 8, 5), const Radius.circular(2)),
        Paint()..color = const Color(0xFFFFF59D));
  }
}

/// Schatten der Figur auf dem Asphalt – wird grösser, je näher sie kommt.
class GroundShadow extends PositionComponent with HasGameReference<CliffDiveGame> {
  GroundShadow() : super(priority: 6);

  @override
  void render(Canvas canvas) {
    final d = game.diver;
    final height = (-d.position.y).clamp(0.0, 600.0);
    final k = 1 - height / 600;
    if (k <= 0) return;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(d.position.x, 3), width: 26 + 20 * k, height: 6),
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, 0.45 * k)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
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
      ..color = const Color(0xFF111214)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final n = big ? 9 : 5;
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 3), width: 60 * _t, height: 8 * _t),
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    for (var i = 0; i < n; i++) {
      final ang = -math.pi + (i + 0.5) * math.pi / n * 2;
      var pt = Offset.zero;
      final len = (big ? 54.0 : 24.0) * _t;
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

/// Drei Männer auf ihrem Balkon, rauchen und lächeln.
class SmokingMen extends PositionComponent {
  SmokingMen({required this.wallX, required this.floorY}) : super(priority: 2);

  final double wallX;
  final double floorY;
  double _t = 0;

  static const _men = [
    CharacterDef(id: 'n1', name: '', price: 0, skin: Color(0xFFE9B994), hair: Color(0xFF3B2A1E),
        hairStyle: HairStyle.short, body: BodyType.male, beard: Color(0xFF3B2A1E)),
    CharacterDef(id: 'n2', name: '', price: 0, skin: Color(0xFF8A5A3C), hair: Color(0xFF151010),
        hairStyle: HairStyle.buzz, body: BodyType.male),
    CharacterDef(id: 'n3', name: '', price: 0, skin: Color(0xFFF2CCAE), hair: Color(0xFF9E9E9E),
        hairStyle: HairStyle.short, body: BodyType.male, beard: Color(0xFFBDBDBD)),
  ];
  static const _clothes = [
    OutfitDef(id: 'm1', name: '', price: 0, top: Color(0xFFF5F5F5), bottom: Color(0xFF455A64),
        bottomStyle: BottomStyle.pants, shoes: Color(0xFF3E2723)),
    OutfitDef(id: 'm2', name: '', price: 0, top: Color(0xFF2E7D32), bottom: Color(0xFF212121),
        bottomStyle: BottomStyle.shorts, shoes: Color(0xFFFAFAFA)),
    OutfitDef(id: 'm3', name: '', price: 0, top: Color(0xFF5C6BC0), bottom: Color(0xFF8D6E63),
        bottomStyle: BottomStyle.pants, shoes: Color(0xFF212121), longSleeves: true),
  ];

  static const double depth = 62;

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    // breiterer Balkon
    canvas.drawRect(Rect.fromLTWH(wallX, floorY, depth, 8),
        Paint()
          ..shader = Gradient.linear(Offset(0, floorY), Offset(0, floorY + 8),
              const [Color(0xFFE6E8EA), Color(0xFF9EA6AE)]));
    final xs = [wallX + 12, wallX + 30, wallX + 47];
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(xs[i], floorY - 34 * 0.92);
      canvas.scale(0.92);
      // mittlerer Mann schaut nach links zu den anderen
      if (i == 1) canvas.scale(-1, 1);
      final pose = i == 1 && (_t % 6) < 3 ? Pose.stand : Pose.smoke;
      WomanPainter.paint(canvas,
          pose: pose, character: _men[i], outfit: _clothes[i], grounded: true, smile: true, time: _t);
      if (pose == Pose.smoke) _cigarette(canvas, i);
      canvas.restore();
    }
    // Glasgeländer davor
    canvas.drawRect(Rect.fromLTWH(wallX, floorY - 28, depth, 28),
        Paint()
          ..shader = Gradient.linear(Offset(wallX, floorY - 28), Offset(wallX + depth, floorY),
              const [Color(0x5590CAF9), Color(0x33FFFFFF)]));
    canvas.drawRect(Rect.fromLTWH(wallX, floorY - 31, depth, 3), Paint()..color = const Color(0xFFB0BEC5));
    canvas.drawRect(Rect.fromLTWH(wallX + depth - 2, floorY - 31, 2, 31), Paint()..color = const Color(0xFF90A4AE));
  }

  void _cigarette(Canvas canvas, int i) {
    final hand = WomanPainter.frontHand(Pose.smoke, grounded: true) + const Offset(0.5, -1.0);
    canvas.drawLine(hand, hand + const Offset(4, -0.6),
        Paint()
          ..color = const Color(0xFFF5F5F5)
          ..strokeWidth = 1.1);
    final glow = 0.6 + 0.4 * math.sin(_t * 3 + i);
    canvas.drawCircle(hand + const Offset(4.2, -0.6), 0.8,
        Paint()..color = Color.fromRGBO(255, 112, 67, glow));
    // aufsteigender Rauch
    for (var k = 0; k < 4; k++) {
      final ph = (_t * 0.6 + k / 4 + i * 0.3) % 1.0;
      final p = hand + Offset(4.5 + math.sin(ph * 6 + i) * 3 * ph, -2 - ph * 26);
      canvas.drawCircle(p, 1.5 + ph * 4,
          Paint()
            ..color = Color.fromRGBO(230, 230, 230, 0.45 * (1 - ph))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
    }
  }
}

/// Party-Club am Strassenrand – das Ziel nach 10 guten Landungen.
class PartyClub extends PositionComponent {
  PartyClub({required Vector2 position}) : super(position: position, priority: 7);

  double _t = 0;

  /// x-Position der Tür relativ zum Club.
  static const double doorX = 70;

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    // Lichtkegel vom Dach
    for (var i = 0; i < 3; i++) {
      final a = math.sin(_t * 1.3 + i * 2) * 0.5 - math.pi / 2;
      final o = Offset(40.0 + i * 60, -200);
      final p = Path()
        ..moveTo(o.dx, o.dy)
        ..lineTo(o.dx + math.cos(a - 0.08) * 900, o.dy + math.sin(a - 0.08) * 900)
        ..lineTo(o.dx + math.cos(a + 0.08) * 900, o.dy + math.sin(a + 0.08) * 900)
        ..close();
      canvas.drawPath(p,
          Paint()
            ..color = [const Color(0x33E040FB), const Color(0x3340C4FF), const Color(0x33FFEB3B)][i]
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    // Gebäude
    canvas.drawRect(const Rect.fromLTWH(0, -200, 200, 200),
        Paint()
          ..shader = Gradient.linear(const Offset(0, -200), Offset.zero,
              const [Color(0xFF2B1F3A), Color(0xFF1A1424)]));
    // Neon-Schild
    final glowCol = Color.lerp(const Color(0xFFFF4FD8), const Color(0xFF52E5FF), (math.sin(_t * 2) + 1) / 2)!;
    final pb = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center, fontSize: 30))
      ..pushStyle(TextStyle(
        color: const Color(0xFFFFFFFF),
        fontSize: 30,
        fontWeight: FontWeight.w900,
        shadows: [Shadow(color: glowCol, blurRadius: 12), Shadow(color: glowCol, blurRadius: 4)],
      ))
      ..addText('PARTY');
    final para = pb.build()..layout(const ParagraphConstraints(width: 200));
    canvas.drawParagraph(para, const Offset(0, -175));
    // Fenster mit Discolicht
    for (var i = 0; i < 4; i++) {
      final c = HSVColor.fromAHSV(1, (_t * 90 + i * 70) % 360, 0.7, 1).toColor();
      canvas.drawRect(Rect.fromLTWH(14.0 + i * 46, -120, 30, 26), Paint()..color = c.withValues(alpha: 0.75));
    }
    // Tür
    canvas.drawRect(const Rect.fromLTWH(doorX - 18, -62, 36, 62),
        Paint()
          ..shader = Gradient.linear(const Offset(0, -62), Offset.zero,
              const [Color(0xFFFFD180), Color(0xFFFF6E40)]));
    // roter Teppich und Absperrung
    canvas.drawRect(const Rect.fromLTWH(doorX - 40, -2, 80, 6), Paint()..color = const Color(0xFFC62828));
    final gold = Paint()..color = const Color(0xFFD4AF37);
    for (final x in const [doorX - 44.0, doorX + 44.0]) {
      canvas.drawRect(Rect.fromLTWH(x - 1.5, -26, 3, 26), gold);
      canvas.drawCircle(Offset(x, -27), 3, gold);
    }
  }
}
