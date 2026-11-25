import 'package:flutter/painting.dart';

/// Ein Absprungort.
class JumpLevel {
  const JumpLevel({
    required this.id,
    required this.name,
    required this.heightMeters,
    required this.floor,
    required this.skyTop,
    required this.skyBottom,
  });

  final String id;
  final String name;
  final double heightMeters;

  /// Stockwerk des Balkons (nur Anzeige).
  final int floor;
  final Color skyTop;
  final Color skyBottom;

  static const tower = JumpLevel(
    id: 'tower',
    name: 'Hochhaus',
    heightMeters: 24,
    floor: 8,
    skyTop: Color(0xFF6E9BC8),
    skyBottom: Color(0xFFF3D3B0),
  );
}
