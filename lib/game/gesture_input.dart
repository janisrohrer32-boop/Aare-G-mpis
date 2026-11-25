import 'dart:ui';

enum SwipeDirection { up, down, left, right }

/// Wertet rohe Finger-Events aus: Halten, Tippen und Wischen.
///
/// Unabhängig von Flame, damit es leicht testbar ist.
class GestureInput {
  GestureInput({
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.onTap,
    required this.onSwipe,
  });

  final void Function() onHoldStart;
  final void Function() onHoldEnd;
  final void Function() onTap;
  final void Function(SwipeDirection) onSwipe;

  /// Ab dieser Strecke (logische Pixel) gilt eine Bewegung als Wisch.
  static const double swipeDistance = 35;

  Offset? _start;
  bool _swiped = false;

  void pointerDown(Offset pos) {
    _start = pos;
    _swiped = false;
    onHoldStart();
  }

  void pointerMove(Offset pos) {
    final s = _start;
    if (s == null || _swiped) return;
    final d = pos - s;
    if (d.distance >= swipeDistance) {
      _swiped = true;
      onSwipe(directionOf(d));
    }
  }

  void pointerUp(Offset pos) {
    final s = _start;
    _start = null;
    if (s != null && !_swiped) {
      final d = pos - s;
      if (d.distance >= swipeDistance) {
        onSwipe(directionOf(d));
      } else {
        onTap();
      }
    }
    // Erst danach: so wird das Loslassen auf der Klippe nicht
    // gleichzeitig als Tippen in der Luft gezählt.
    onHoldEnd();
  }

  static SwipeDirection directionOf(Offset d) {
    if (d.dx.abs() > d.dy.abs()) {
      return d.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    }
    return d.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
  }
}
