import 'dart:ui';

import 'package:flame/components.dart';

import '../models/cliff_level.dart';

/// Die Klippe. Die Kante liegt bei [edgeX], die Oberkante bei [topY].
class Cliff extends PositionComponent {
  Cliff({required this.level, required this.edgeX, required this.topY});

  final CliffLevel level;
  final double edgeX;
  final double topY;

  @override
  void render(Canvas canvas) {
    final rock = Paint()..color = level.rockColor;
    final dark = Paint()..color = Color.lerp(level.rockColor, const Color(0xFF000000), 0.25)!;
    final path = Path()
      ..moveTo(edgeX - 1200, topY)
      ..lineTo(edgeX, topY)
      ..quadraticBezierTo(edgeX + 6, topY + 20, edgeX - 4, topY + 60)
      ..lineTo(edgeX - 18, -topY * 0.35 + topY)
      ..quadraticBezierTo(edgeX + 4, topY * 0.4, edgeX - 26, 0)
      ..lineTo(edgeX - 40, 400)
      ..lineTo(edgeX - 1200, 400)
      ..close();
    canvas.drawPath(path, rock);
    // Schattierung / Felsstreifen
    for (var i = 1; i < 5; i++) {
      final y = topY + (-topY) * i / 5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(edgeX - 140 - i * 20, y, 90, 10), const Radius.circular(5)),
        dark,
      );
    }
    // Gras oben
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(edgeX - 1200, topY - 6, 1206, 14), const Radius.circular(7)),
      Paint()..color = const Color(0xFF7CB342),
    );
    // Höhenschild
    final sign = Paint()..color = const Color(0xFFFFF8E1);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(edgeX - 120, topY - 46, 44, 24), const Radius.circular(6)),
        sign);
    canvas.drawRect(Rect.fromLTWH(edgeX - 100, topY - 22, 4, 18), sign);
    final pb = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center, fontSize: 13))
      ..pushStyle(TextStyle(
          color: const Color(0xFF5D4037), fontWeight: FontWeight.bold, fontSize: 13))
      ..addText('${level.heightMeters.toStringAsFixed(0)} m');
    final p = pb.build()..layout(const ParagraphConstraints(width: 44));
    canvas.drawParagraph(p, Offset(edgeX - 120, topY - 42));
  }
}
