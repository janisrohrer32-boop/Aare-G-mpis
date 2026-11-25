import 'dart:math' as math;

import 'package:cliff_dive/game/gesture_input.dart';
import 'package:cliff_dive/models/landing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LandingJudge', () {
    test('gerade und gestreckt = Perfekt', () {
      final r = LandingJudge.judge(angle: 0.05, stretched: true, trickInProgress: false);
      expect(r.quality, LandingQuality.perfect);
    });
    test('Kopf voraus nach Salto zählt auch', () {
      final r = LandingJudge.judge(
          angle: -2 * math.pi - math.pi, stretched: true, trickInProgress: false);
      expect(r.quality, LandingQuality.perfect);
    });
    test('nicht gestreckt = Gut', () {
      final r = LandingJudge.judge(angle: 0, stretched: false, trickInProgress: false);
      expect(r.quality, LandingQuality.good);
    });
    test('quer = Bauchklatscher', () {
      final r = LandingJudge.judge(angle: math.pi / 2, stretched: true, trickInProgress: false);
      expect(r.quality, LandingQuality.bellyFlop);
      expect(r.multiplier, 0);
    });
    test('Trick noch nicht fertig = kein Perfekt', () {
      final r = LandingJudge.judge(angle: 0.1, stretched: true, trickInProgress: true);
      expect(r.quality, LandingQuality.good);
    });
  });

  group('GestureInput', () {
    late List<String> log;
    late GestureInput input;
    setUp(() {
      log = [];
      input = GestureInput(
        onHoldStart: () => log.add('down'),
        onHoldEnd: () => log.add('up'),
        onTap: () => log.add('tap'),
        onSwipe: (d) => log.add(d.name),
      );
    });
    test('Wisch nach oben', () {
      input.pointerDown(const Offset(100, 300));
      input.pointerMove(const Offset(100, 250));
      input.pointerUp(const Offset(100, 240));
      expect(log, ['down', 'up', 'up']);
    });
    test('Tippen wird vor dem Loslassen gemeldet', () {
      input.pointerDown(const Offset(100, 300));
      input.pointerUp(const Offset(102, 301));
      expect(log, ['down', 'tap', 'up']);
    });
  });
}
