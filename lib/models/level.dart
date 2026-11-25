import 'package:flutter/painting.dart';

/// Ort und Regeln des Endlos-Laufs.
class JumpLevel {
  const JumpLevel({
    required this.id,
    required this.name,
    required this.startFloor,
    required this.floorsPerJump,
    required this.floorHeightMeters,
    required this.skyTop,
    required this.skyBottom,
  });

  final String id;
  final String name;

  /// Stockwerk beim ersten Sprung.
  final int startFloor;

  /// Um so viele Stockwerke geht es nach jedem Sprung höher.
  final int floorsPerJump;
  final double floorHeightMeters;
  final Color skyTop;
  final Color skyBottom;

  double heightOf(int floor) => floor * floorHeightMeters;

  static const tower = JumpLevel(
    id: 'tower',
    name: 'Hochhaus',
    startFloor: int.fromEnvironment('START_FLOOR', defaultValue: 8),
    floorsPerJump: 3,
    floorHeightMeters: 3,
    skyTop: Color(0xFF5B86B5),
    skyBottom: Color(0xFFF2CFA8),
  );
}
