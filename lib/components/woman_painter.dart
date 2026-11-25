import 'dart:math' as math;
import 'dart:ui';

import '../models/character.dart';

/// Gelenkwinkel einer Körperhaltung.
///
/// Absolute Winkel: 0 = nach oben, π/2 = nach vorne (Blickrichtung),
/// π = nach unten. Ellbogen/Knie sind relativ zum Oberarm/Oberschenkel.
/// "F" = vorderer (zum Betrachter) Arm/Bein, "B" = hinterer.
class Pose {
  const Pose({
    required this.torso,
    required this.shoulderF,
    required this.elbowF,
    required this.shoulderB,
    required this.elbowB,
    required this.hipF,
    required this.kneeF,
    required this.hipB,
    required this.kneeB,
  });

  final double torso, shoulderF, elbowF, shoulderB, elbowB, hipF, kneeF, hipB, kneeB;

  static Pose lerp(Pose a, Pose b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return Pose(
      torso: l(a.torso, b.torso),
      shoulderF: l(a.shoulderF, b.shoulderF),
      elbowF: l(a.elbowF, b.elbowF),
      shoulderB: l(a.shoulderB, b.shoulderB),
      elbowB: l(a.elbowB, b.elbowB),
      hipF: l(a.hipF, b.hipF),
      kneeF: l(a.kneeF, b.kneeF),
      hipB: l(a.hipB, b.hipB),
      kneeB: l(a.kneeB, b.kneeB),
    );
  }

  static const pi = math.pi;

  static const stand = Pose(
      torso: 0, shoulderF: pi - 0.12, elbowF: -0.25, shoulderB: pi + 0.1, elbowB: -0.2,
      hipF: pi - 0.06, kneeF: 0.06, hipB: pi + 0.07, kneeB: 0.02);

  static const crouch = Pose(
      torso: 0.45, shoulderF: pi + 0.9, elbowF: 0.1, shoulderB: pi + 0.7, elbowB: 0.1,
      hipF: pi / 2 + 0.5, kneeF: 1.3, hipB: pi / 2 + 0.6, kneeB: 1.35);

  static const air = Pose(
      torso: 0, shoulderF: 1.9, elbowF: -0.3, shoulderB: -1.5, elbowB: 0.3,
      hipF: pi - 0.25, kneeF: 0.35, hipB: pi + 0.15, kneeB: 0.25);

  static const tuck = Pose(
      torso: 0.25, shoulderF: 1.6, elbowF: 1.0, shoulderB: 1.5, elbowB: 1.1,
      hipF: 1.1, kneeF: 1.84, hipB: 1.2, kneeB: 1.8);

  static const stretch = Pose(
      torso: 0, shoulderF: 0.05, elbowF: 0, shoulderB: -0.05, elbowB: 0,
      hipF: pi, kneeF: 0, hipB: pi + 0.04, kneeB: 0);

  static const hero = Pose(
      torso: 0.5, shoulderF: pi - 0.3, elbowF: 0, shoulderB: -1.2, elbowB: -0.2,
      hipF: pi / 2 + 0.05, kneeF: 1.5, hipB: pi + 0.1, kneeB: 1.42);

  static const sprawl = Pose(
      torso: 0, shoulderF: 0.8, elbowF: 0.6, shoulderB: -0.9, elbowB: -0.5,
      hipF: pi - 0.4, kneeF: 0.9, hipB: pi + 0.3, kneeB: 0.3);
}

/// Zeichnet die Figur (Seitenansicht, Blick nach rechts).
/// Wird im Spiel und im Shop (Vorschau) verwendet.
class WomanPainter {
  static const double torsoLen = 21, upperArm = 12, foreArm = 11, thigh = 16.5, shin = 16;
  static const double headR = 5.2;

  static Offset dir(double a) => Offset(math.sin(a), -math.cos(a));

  /// Zeichnet um den Ursprung (Körpermitte). Mit [grounded] werden die
  /// Kontaktpunkte (Füße, Knie, Hände) auf [groundY] gesetzt.
  static void paint(
    Canvas canvas, {
    required Pose pose,
    required CharacterDef character,
    required OutfitDef outfit,
    int style = 3,
    double time = 0,
    bool grounded = false,
    double groundY = 34,
  }) {
    var hip = const Offset(0, 4);
    var j = _Joints(pose, hip);
    if (grounded) {
      final maxY = [j.footF, j.footB, j.kneeF, j.kneeB, j.handF, j.handB]
          .map((o) => o.dy)
          .reduce(math.max);
      hip = hip.translate(0, groundY - maxY);
      j = _Joints(pose, hip);
    }

    final skin = character.skin;
    final shade = Color.lerp(skin, const Color(0xFF000000), 0.18)!;
    final o = outfit;
    final legCovered = o.bottomStyle == BottomStyle.leggings || o.bottomStyle == BottomStyle.pants;

    // Umhang (hinter allem)
    if (o.cape != null) {
      final u = dir(pose.torso), n = dir(pose.torso + math.pi / 2);
      final wave = math.sin(time * 9) * 2.5;
      final p = Path()
        ..moveTo(j.neck.dx - n.dx * 3, j.neck.dy - n.dy * 3)
        ..quadraticBezierTo(
            j.hip.dx - n.dx * 14 + wave, j.hip.dy - n.dy * 14,
            j.hip.dx - n.dx * 16 - u.dx * 10 + wave, j.hip.dy - n.dy * 16 - u.dy * 10)
        ..lineTo(j.hip.dx - n.dx * 4 - u.dx * 6, j.hip.dy - n.dy * 4 - u.dy * 6)
        ..close();
      canvas.drawPath(p, Paint()..color = o.cape!);
    }

    // Hinterer Arm und hinteres Bein (etwas dunkler)
    _arm(canvas, j.shoulder, j.elbowB, j.handB, shade, o, darker: true);
    _leg(canvas, j.hip, j.kneeB, j.footB, shade, o, legCovered, darker: true);

    // Rumpf
    _torso(canvas, pose, j, skin, o, style);

    // Vorderes Bein
    _leg(canvas, j.hip, j.kneeF, j.footF, skin, o, legCovered);
    if (o.bottomStyle == BottomStyle.skirt) _skirt(canvas, pose, j, o);

    // Kopf
    _head(canvas, j.head, pose.torso, character, o, style, time);

    // Vorderer Arm
    _arm(canvas, j.shoulder, j.elbowF, j.handF, skin, o);
  }

  static Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static Color _dark(Color c, bool darker) =>
      darker ? Color.lerp(c, const Color(0xFF000000), 0.22)! : c;

  /// Glied mit Licht- und Schattenkante (Licht kommt von rechts oben).
  static void _limb(Canvas c, Offset a, Offset b, Color color, double w) {
    c.drawLine(a, b, _stroke(color, w));
    final d = b - a;
    final len = d.distance;
    if (len == 0) return;
    final n = Offset(-d.dy / len, d.dx / len);
    // Seite, die zur Lichtquelle zeigt
    final lightSide = (n.dx - n.dy) >= 0 ? n : -n;
    c.drawLine(a + lightSide * (w * 0.22), b + lightSide * (w * 0.22),
        _stroke(Color.lerp(color, const Color(0xFFFFFFFF), 0.22)!, w * 0.28));
    c.drawLine(a - lightSide * (w * 0.3), b - lightSide * (w * 0.3),
        _stroke(Color.lerp(color, const Color(0xFF000000), 0.2)!, w * 0.25));
  }

  static void _arm(Canvas c, Offset s, Offset e, Offset h, Color skin, OutfitDef o,
      {bool darker = false}) {
    final sleeve = o.longSleeves ? _dark(o.top, darker) : skin;
    _limb(c, s, e, o.longSleeves ? sleeve : skin, 4.2);
    if (!o.longSleeves) {
      // kurzer Ärmel
      c.drawLine(s, Offset.lerp(s, e, 0.35)!, _stroke(_dark(o.top, darker), 4.8));
    }
    _limb(c, e, h, o.longSleeves ? sleeve : skin, 3.4);
    if (o.longSleeves) {
      c.drawLine(Offset.lerp(e, h, 0.85)!, h, _stroke(skin, 3.6));
    }
    c.drawCircle(h, 2.0, Paint()..color = skin);
  }

  static void _leg(Canvas c, Offset hip, Offset k, Offset f, Color skin, OutfitDef o,
      bool covered,
      {bool darker = false}) {
    final cloth = _dark(o.bottom, darker);
    _limb(c, hip, k, covered ? cloth : skin, 6.4);
    _limb(c, k, f, covered ? cloth : skin, 4.6);
    if (o.bottomStyle == BottomStyle.shorts) {
      c.drawLine(hip, Offset.lerp(hip, k, 0.45)!, _stroke(cloth, 7.4));
    }
    // Schuh: zeigt nach vorne (senkrecht zum Unterschenkel)
    final sd = f - k;
    final len = sd.distance == 0 ? 1.0 : sd.distance;
    final fwd = Offset(-sd.dy / len, sd.dx / len);
    final toe = f + fwd * 4.5;
    c.drawLine(f - fwd * 1.5, toe, _stroke(_dark(o.shoes, darker), 4.2));
  }

  static void _torso(Canvas c, Pose pose, _Joints j, Color skin, OutfitDef o, int style) {
    final u = dir(pose.torso), n = dir(pose.torso + math.pi / 2);
    Offset at(double t, double side) => j.hip + u * (torsoLen * t) + n * side;

    Path shape(double from, double to) {
      // Vorder- und Rückenkontur (Seitenansicht, weiblich)
      const front = [[0.0, 4.4], [0.35, 3.4], [0.62, 4.0], [0.74, 6.0], [0.86, 5.0], [1.0, 3.2]];
      const back = [[0.0, -5.6], [0.18, -5.4], [0.4, -3.6], [0.75, -4.3], [1.0, -3.8]];
      List<Offset> pts(List<List<double>> prof) {
        final r = <Offset>[];
        for (var i = 0; i < prof.length; i++) {
          final t = prof[i][0];
          if (t < from - 0.001 || t > to + 0.001) continue;
          r.add(at(t, prof[i][1]));
        }
        return r;
      }

      double interp(List<List<double>> prof, double t) {
        for (var i = 0; i < prof.length - 1; i++) {
          final a = prof[i], b = prof[i + 1];
          if (t >= a[0] && t <= b[0]) {
            return a[1] + (b[1] - a[1]) * (t - a[0]) / (b[0] - a[0]);
          }
        }
        return prof.last[1];
      }

      final f = [at(from, interp(front, from)), ...pts(front), at(to, interp(front, to))];
      final b = [at(to, interp(back, to)), ...pts(back).reversed, at(from, interp(back, from))];
      final p = Path()..moveTo(f.first.dx, f.first.dy);
      for (final q in [...f.skip(1), ...b]) {
        p.lineTo(q.dx, q.dy);
      }
      return p..close();
    }

    Paint shaded(Color col) => Paint()
      ..shader = Gradient.linear(at(0.5, 6), at(0.5, -6), [
        Color.lerp(col, const Color(0xFFFFFFFF), 0.15)!,
        col,
        Color.lerp(col, const Color(0xFF000000), 0.28)!,
      ], const [0, 0.45, 1]);

    // Haut darunter
    c.drawPath(shape(0, 1), shaded(skin));
    // Hose / Unterteil
    if (o.bottomStyle != BottomStyle.skirt) {
      c.drawPath(shape(0, 0.36), shaded(o.bottom));
    }
    // Oberteil
    final topFrom = o.id == 'sport' ? 0.55 : (o.bottomStyle == BottomStyle.skirt ? 0.0 : 0.3);
    c.drawPath(shape(topFrom, 1), shaded(o.top));
    // Stofffalten
    final fold = _stroke(Color.lerp(o.top, const Color(0xFF000000), 0.25)!, 0.7);
    c.drawLine(at(topFrom + 0.08, 1.5), at(topFrom + 0.2, -1.0), fold);
    c.drawLine(at(0.82, 3.0), at(0.7, 0.5), fold);
    if (o.accent != null) {
      c.drawLine(at(0.55, 4.2), at(0.95, 4.0), _stroke(o.accent!, 1.4));
    }
    if (o.belt != null) {
      c.drawLine(at(0.36, 3.6), at(0.36, -3.8), _stroke(o.belt!, 2.2));
    }
    // Lederjacke: offener Kragen
    if (o.id == 'leather') {
      c.drawLine(at(0.95, 3.5), at(0.6, 1.0), _stroke(o.accent!, 1.0));
    }
    // Schmutz / Risse bei niedrigem Style
    if (style <= 1) {
      final dirt = Paint()..color = const Color(0x665D4037);
      c.drawCircle(at(0.5, 1.5), 1.6, dirt);
      c.drawCircle(at(0.2, -2), 1.2, dirt);
      if (style == 0) {
        final tear = _stroke(const Color(0xAA000000), 0.9);
        c.drawLine(at(0.7, 3), at(0.6, 0), tear);
        c.drawLine(at(0.6, 0), at(0.66, -2), tear);
      }
    }
  }

  static void _skirt(Canvas c, Pose pose, _Joints j, OutfitDef o) {
    final u = dir(pose.torso), n = dir(pose.torso + math.pi / 2);
    final kneeMid = Offset.lerp(j.kneeF, j.kneeB, 0.5)!;
    final down = kneeMid - j.hip;
    final hemC = j.hip + down * 0.85;
    final d = down.distance == 0 ? const Offset(0, 1) : down / down.distance;
    final side = Offset(-d.dy, d.dx);
    final p = Path()
      ..moveTo((j.hip + u * 7 + n * 4).dx, (j.hip + u * 7 + n * 4).dy)
      ..lineTo((hemC + side * 8).dx, (hemC + side * 8).dy)
      ..lineTo((hemC - side * 8).dx, (hemC - side * 8).dy)
      ..lineTo((j.hip + u * 7 - n * 5).dx, (j.hip + u * 7 - n * 5).dy)
      ..close();
    c.drawPath(p, Paint()..color = o.bottom);
    if (o.accent != null) {
      c.drawLine(hemC + side * 7.5, hemC - side * 7.5, _stroke(o.accent!, 1.2));
    }
  }

  static void _head(Canvas c, Offset center, double torso, CharacterDef ch, OutfitDef o,
      int style, double time) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(torso * 0.7);
    c.scale(headR / 6.6);
    final hair = Paint()
      ..shader = Gradient.linear(const Offset(0, -7), const Offset(0, 12), [
        Color.lerp(ch.hair, const Color(0xFFFFFFFF), 0.18)!,
        ch.hair,
        Color.lerp(ch.hair, const Color(0xFF000000), 0.35)!,
      ], const [0, 0.4, 1]);
    const r = 6.6;

    // Haare hinten
    switch (ch.hairStyle) {
      case HairStyle.long:
        final p = Path()
          ..moveTo(-1, -r)
          ..quadraticBezierTo(-r - 3, -2, -r - 2, r + 9)
          ..lineTo(-1, r + 7)
          ..close();
        c.drawPath(p, hair);
      case HairStyle.ponytail:
        final sway = math.sin(time * 7) * 2;
        final p = Path()
          ..moveTo(-r + 1, -3)
          ..quadraticBezierTo(-r - 8, -2 + sway, -r - 5 + sway, 10)
          ..quadraticBezierTo(-r - 3, 2, -r + 2, 0)
          ..close();
        c.drawPath(p, hair);
        c.drawCircle(Offset(-r + 0.5, -2.5), 1.6, Paint()..color = const Color(0xFFE91E63));
      case HairStyle.bun:
        c.drawCircle(Offset(-r + 1, -r + 1), 4.2, hair);
      case HairStyle.bob:
        c.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(-r - 1.5, -r, r + 2, 2 * r + 1.5),
                const Radius.circular(4)),
            hair);
    }

    // Hals + Gesicht
    c.drawRect(Rect.fromLTWH(-2.2, r - 3, 4.4, 5), Paint()..color = ch.skin);
    c.drawOval(Rect.fromCenter(center: const Offset(0.4, 0.4), width: 2 * r, height: 2 * r + 1.6),
        Paint()..color = ch.skin);
    // Nase und Kinn
    final nose = Path()
      ..moveTo(r - 0.6, -1.2)
      ..lineTo(r + 1.5, 1.6)
      ..lineTo(r - 0.2, 2.2)
      ..close();
    c.drawPath(nose, Paint()..color = ch.skin);
    // Ohr
    c.drawOval(Rect.fromCenter(center: const Offset(-1.2, 0.8), width: 2.4, height: 3.4),
        Paint()..color = Color.lerp(ch.skin, const Color(0xFF000000), 0.12)!);

    // Maske (Superheldin / Ninja)
    if (o.mask != null) {
      if (o.id == 'ninja') {
        c.drawRect(Rect.fromLTWH(-r, 0.8, 2 * r + 1.6, r), Paint()..color = o.mask!);
      }
      c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(-r, -3.4, 2 * r + 0.8, 3.6),
              const Radius.circular(1.5)),
          Paint()..color = o.mask!);
    }

    // Auge
    c.drawOval(Rect.fromCenter(center: const Offset(3.4, -1.4), width: 3.2, height: 2.1),
        Paint()..color = const Color(0xFFFFFFFF));
    c.drawCircle(const Offset(4.0, -1.4), 1.0, Paint()..color = ch.eyes);
    c.drawCircle(const Offset(4.2, -1.5), 0.45, Paint()..color = const Color(0xFF000000));
    // Wimpern und Augenbraue
    c.drawLine(const Offset(1.8, -2.5), const Offset(5.2, -2.5),
        _stroke(const Color(0xFF1A1A1A), 0.8));
    c.drawLine(const Offset(5.0, -2.6), const Offset(5.9, -3.1),
        _stroke(const Color(0xFF1A1A1A), 0.6));
    c.drawLine(const Offset(2.0, -4.3), const Offset(5.4, -4.0),
        _stroke(Color.lerp(ch.hair, const Color(0xFF000000), 0.3)!, 0.8));
    // Lippen
    if (o.id != 'ninja') {
      c.drawOval(Rect.fromCenter(center: const Offset(5.0, 3.6), width: 2.8, height: 1.4),
          Paint()..color = ch.lips);
      // Wangen
      c.drawCircle(const Offset(2.6, 1.8), 1.3,
          Paint()..color = const Color(0x33E57373));
    }

    // Haare oben (Pony)
    final top = Path()
      ..moveTo(r + 0.4, -2.6)
      ..quadraticBezierTo(r, -r - 1.5, 0, -r - 1.2)
      ..quadraticBezierTo(-r - 1.4, -r, -r - 0.6, 1.5)
      ..lineTo(-2, 0)
      ..quadraticBezierTo(1, -4, r + 0.4, -2.6)
      ..close();
    c.drawPath(top, hair);
    if (ch.hairStyle == HairStyle.bob) {
      c.drawRect(Rect.fromLTWH(-r - 1, -1, 3.5, r + 1), hair);
    }

    // Style-Effekte
    if (style >= 4) {
      // glänzende Haare
      c.drawLine(Offset(-3, -r + 0.2), Offset(2, -r - 0.4),
          _stroke(const Color(0x88FFFFFF), 1.1));
    }
    if (style >= 5 && o.mask == null) {
      // Sonnenbrille im Haar
      c.drawLine(Offset(-1, -r - 0.8), Offset(4.5, -r + 0.4),
          _stroke(const Color(0xFF212121), 1.8));
    }
    if (style <= 1) {
      // zerzauste Haare
      final s = _stroke(ch.hair, 0.9);
      c.drawLine(Offset(-2, -r - 1), Offset(-4, -r - 4), s);
      c.drawLine(Offset(1, -r - 1), Offset(2, -r - 4.5), s);
      c.drawLine(Offset(-5, -r + 1), Offset(-8, -r - 1), s);
      c.drawCircle(Offset(1.5, 2.6), 1.0, Paint()..color = const Color(0x665D4037));
    }
    if (style == 0) {
      // Pflaster
      c.save();
      c.translate(2.2, 1.8);
      c.rotate(-0.5);
      c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 4.4, height: 1.8),
              const Radius.circular(0.8)),
          Paint()..color = const Color(0xFFFFE0B2));
      c.restore();
    }
    c.restore();
  }
}

class _Joints {
  _Joints(Pose p, this.hip) {
    final u = WomanPainter.dir(p.torso);
    neck = hip + u * WomanPainter.torsoLen;
    shoulder = hip + u * (WomanPainter.torsoLen - 2);
    head = neck + u * (2.5 + WomanPainter.headR);
    elbowF = shoulder + WomanPainter.dir(p.shoulderF) * WomanPainter.upperArm;
    handF = elbowF + WomanPainter.dir(p.shoulderF + p.elbowF) * WomanPainter.foreArm;
    elbowB = shoulder + WomanPainter.dir(p.shoulderB) * WomanPainter.upperArm;
    handB = elbowB + WomanPainter.dir(p.shoulderB + p.elbowB) * WomanPainter.foreArm;
    kneeF = hip + WomanPainter.dir(p.hipF) * WomanPainter.thigh;
    footF = kneeF + WomanPainter.dir(p.hipF + p.kneeF) * WomanPainter.shin;
    kneeB = hip + WomanPainter.dir(p.hipB) * WomanPainter.thigh;
    footB = kneeB + WomanPainter.dir(p.hipB + p.kneeB) * WomanPainter.shin;
  }

  final Offset hip;
  late final Offset neck, shoulder, head, elbowF, handF, elbowB, handB, kneeF, footF, kneeB, footB;
}
