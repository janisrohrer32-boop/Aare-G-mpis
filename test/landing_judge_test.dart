import 'dart:math' as math;

import 'package:cliff_dive/game/gesture_input.dart';
import 'package:cliff_dive/game/spin.dart';
import 'package:cliff_dive/models/landing.dart';
import 'package:cliff_dive/models/trick.dart';
import 'package:cliff_dive/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LandingJudge', () {
    test('aufrecht und ruhig = Superhelden-Landung', () {
      expect(LandingJudge.judge(angle: 0.1, spin: 0.5).quality, LandingQuality.perfect);
    });
    test('nach zwei Saltos wieder aufrecht zählt', () {
      expect(LandingJudge.judge(angle: -4 * math.pi + 0.1, spin: 0).quality,
          LandingQuality.perfect);
    });
    test('noch schnell am Drehen = keine perfekte Landung', () {
      expect(LandingJudge.judge(angle: 0, spin: 5).quality, LandingQuality.good);
      expect(LandingJudge.judge(angle: 0, spin: 9).quality, LandingQuality.crash);
    });
    test('Kopf voraus = Bruchlandung', () {
      expect(LandingJudge.judge(angle: math.pi, spin: 0).quality, LandingQuality.crash);
    });
  });

  group('SpinState', () {
    test('dreht ohne Gegensteuern weiter', () {
      final s = SpinState()..push(-1);
      for (var i = 0; i < 60; i++) {
        s.update(1 / 60);
      }
      expect(s.angle, closeTo(-SpinState.impulse, 0.01));
    });
    test('leichter Absprung-Drall wird beim Wischen überstimmt', () {
      final s = SpinState()
        ..omega = SpinState.jumpSpin
        ..push(-1);
      expect(s.omega, closeTo(SpinState.jumpSpin - SpinState.impulse, 1e-9));
    });
    test('Gegenwischen stoppt die Drehung', () {
      final s = SpinState()
        ..push(-1)
        ..push(1);
      expect(s.omega, 0);
    });
    test('volle Umdrehung rückwärts = Rückwärtssalto', () {
      final s = SpinState()..push(-1);
      final tricks = <Trick>[];
      for (var i = 0; i < 120; i++) {
        tricks.addAll(s.update(1 / 60));
      }
      expect(tricks, [Trick.backflip, Trick.backflip]);
    });
    test('gestreckt dreht langsamer', () {
      final s = SpinState()
        ..push(1)
        ..stretched = true;
      expect(s.effectiveOmega, closeTo(SpinState.impulse * SpinState.stretchFactor, 1e-9));
    });
  });

  group('Shop', () {
    test('kaufen nur mit genug Münzen', () {
      final st = StorageService.inMemory();
      expect(st.buy(kind: 'outfit', id: 'hero', price: 1000), isFalse);
      st.addCoins(1200);
      expect(st.buy(kind: 'outfit', id: 'hero', price: 1000), isTrue);
      expect(st.coins, 200);
      st.selectOutfit('hero');
      expect(st.outfit.id, 'hero');
    });
    test('Style bleibt zwischen 0 und 5', () {
      final st = StorageService.inMemory();
      for (var i = 0; i < 10; i++) {
        st.changeStyle(-1);
      }
      expect(st.style, 0);
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
