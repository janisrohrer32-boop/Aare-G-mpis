import 'package:flutter/painting.dart';

/// Beschreibt eine Klippe mit ihrer Umgebung.
class CliffLevel {
  const CliffLevel({
    required this.id,
    required this.name,
    required this.heightMeters,
    required this.skyTop,
    required this.skyBottom,
    required this.mountainColor,
    required this.waterColor,
    required this.rockColor,
  });

  final String id;
  final String name;
  final double heightMeters;
  final Color skyTop;
  final Color skyBottom;
  final Color mountainColor;
  final Color waterColor;
  final Color rockColor;

  static const bergsee = CliffLevel(
    id: 'bergsee',
    name: 'Bergsee',
    heightMeters: 5,
    skyTop: Color(0xFF4FC3F7),
    skyBottom: Color(0xFFB3E5FC),
    mountainColor: Color(0xFF7E9CB8),
    waterColor: Color(0xFF26A6D1),
    rockColor: Color(0xFF9C7A5B),
  );
}
