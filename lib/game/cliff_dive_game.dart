import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/foundation.dart';

import '../components/background.dart';
import '../components/cliff.dart';
import '../components/diver.dart';
import '../components/floating_text.dart';
import '../components/power_meter.dart';
import '../components/water.dart';
import '../models/cliff_level.dart';
import '../models/landing.dart';
import '../models/trick.dart';
import '../services/storage_service.dart';
import 'gesture_input.dart';

enum DivePhase { ready, charging, flying, splashed }

/// Ergebnis eines Sprungs – wird im Ergebnis-Overlay angezeigt.
class RunResult {
  RunResult({
    required this.landing,
    required this.tricks,
    required this.trickPoints,
    required this.total,
    required this.highscore,
    required this.newHighscore,
  });

  final LandingResult landing;
  final List<Trick> tricks;
  final int trickPoints;
  final int total;
  final int highscore;
  final bool newHighscore;
}

class CliffDiveGame extends FlameGame {
  CliffDiveGame({required this.level, this.storage})
      : super(
          camera: CameraComponent.withFixedResolution(width: viewW, height: viewH),
        );

  static const double viewW = 400;
  static const double viewH = 800;

  /// Pixel pro Meter in der Spielwelt.
  static const double ppm = 40;
  static const double gravity = 9.81 * ppm;
  static const double edgeX = -110;

  /// Horizontale Kameraposition (Klippe etwas mehr ins Bild).
  static const double camX = -40;

  final CliffLevel level;
  final StorageService? storage;

  late final Diver diver;
  late final PowerMeter powerMeter;

  DivePhase phase = DivePhase.ready;
  double power = 0;
  double _chargeTime = 0;
  bool stretched = false;
  final List<Trick> performedTricks = [];
  double _splashTimer = 0;
  double _shake = 0;

  final ValueNotifier<int> liveScore = ValueNotifier(0);
  final ValueNotifier<String> hint =
      ValueNotifier('Halten zum Aufladen – loslassen zum Springen');
  RunResult? lastResult;

  double get topY => -level.heightMeters * ppm;

  late final GestureInput input = GestureInput(
    onHoldStart: _onHoldStart,
    onHoldEnd: _onHoldEnd,
    onTap: _onTap,
    onSwipe: _onSwipe,
  );

  @override
  Color backgroundColor() => level.skyBottom;

  @override
  Future<void> onLoad() async {
    camera.backdrop.add(Sky(level));
    world.addAll([
      ParallaxLayer(level: level, factor: 0.85, kind: 'clouds'),
      ParallaxLayer(level: level, factor: 0.6, kind: 'mountains'),
      Cliff(level: level, edgeX: edgeX, topY: topY),
      Water(level),
    ]);
    diver = Diver();
    world.add(diver);
    powerMeter = PowerMeter()..position = Vector2(viewW - 46, viewH / 2 - 110);
    camera.viewport.add(powerMeter);
    reset();
  }

  /// Setzt alles für einen neuen Sprung zurück.
  void reset() {
    phase = DivePhase.ready;
    power = 0;
    _chargeTime = 0;
    stretched = false;
    performedTricks.clear();
    liveScore.value = 0;
    lastResult = null;
    diver
      ..position = Vector2(edgeX - 16, topY - diver.size.y / 2)
      ..angle = 0
      ..pose = DiverPose.stand
      ..currentTrick = null
      ..velocity.setZero()
      ..scale = Vector2.all(1);
    powerMeter.value = 0;
    camera.viewfinder.position = Vector2(camX, _cameraTargetY());
    hint.value = 'Halten zum Aufladen – loslassen zum Springen';
    overlays.remove('result');
  }

  double _cameraTargetY() =>
      math.min(diver.position.y, -(viewH / 2 - 150));

  // ---------------- Eingabe ----------------

  void _onHoldStart() {
    if (phase != DivePhase.ready) return;
    phase = DivePhase.charging;
    _chargeTime = 0;
    diver.pose = DiverPose.crouch;
    hint.value = 'Loslassen zum Springen!';
  }

  void _onHoldEnd() {
    if (phase != DivePhase.charging) return;
    _jump();
  }

  void _onTap() {
    if (phase != DivePhase.flying || diver.trickInProgress) return;
    stretched = true;
    diver.pose = DiverPose.stretch;
  }

  void _onSwipe(SwipeDirection dir) {
    if (phase != DivePhase.flying || diver.trickInProgress) return;
    final trick = switch (dir) {
      SwipeDirection.up => Trick.backflip,
      SwipeDirection.down => Trick.frontflip,
      _ => null,
    };
    if (trick == null) return;
    stretched = false;
    diver.startTrick(trick);
  }

  void _jump() {
    phase = DivePhase.flying;
    final p = power;
    diver.velocity.setValues((1.2 + 2.3 * p) * ppm, -(2.5 + 3.5 * p) * ppm);
    diver.pose = DiverPose.normal;
    powerMeter.value = 0;
    hint.value = 'Wisch ↑ Rückwärtssalto · Wisch ↓ Vorwärtssalto · Tippen = Strecken';
  }

  // ---------------- Spiel-Schleife ----------------

  @override
  void update(double dt) {
    super.update(dt);
    switch (phase) {
      case DivePhase.ready:
        break;
      case DivePhase.charging:
        _chargeTime += dt;
        // Pendelt hoch und runter – den richtigen Moment erwischen!
        power = (1 - math.cos(_chargeTime * math.pi * 1.2)) / 2;
        powerMeter.value = power;
      case DivePhase.flying:
        _updateFlight(dt);
      case DivePhase.splashed:
        _splashTimer += dt;
        diver.position.y += 60 * dt;
        diver.scale = Vector2.all(math.max(0, 1 - _splashTimer * 1.5));
        if (_splashTimer > 1.3 && !overlays.isActive('result')) {
          overlays.add('result');
        }
    }
    _updateCamera(dt);
  }

  void _updateFlight(double dt) {
    diver.velocity.y += gravity * dt;
    diver.position += diver.velocity * dt;

    final done = diver.updateTrick(dt);
    if (done != null) {
      performedTricks.add(done);
      liveScore.value += done.basePoints;
      world.add(FloatingText(done.name,
          position: diver.position + Vector2(0, -60), color: const Color(0xFFFFEB3B)));
      world.add(FloatingText('+${done.basePoints}',
          position: diver.position + Vector2(0, -28), fontSize: 22));
    }

    if (diver.position.y >= -4) _enterWater();
  }

  void _enterWater() {
    phase = DivePhase.splashed;
    _splashTimer = 0;
    final landing = LandingJudge.judge(
      angle: diver.angle,
      stretched: stretched,
      trickInProgress: diver.trickInProgress,
    );
    final trickPoints = performedTricks.fold<int>(0, (s, t) => s + t.basePoints);
    final total = (trickPoints * landing.multiplier).round() + landing.bonus;

    final best = storage?.highscore(level.id) ?? 0;
    final isNew = total > best;
    storage?.submitScore(level.id, total);

    lastResult = RunResult(
      landing: landing,
      tricks: List.of(performedTricks),
      trickPoints: trickPoints,
      total: total,
      highscore: math.max(best, total),
      newHighscore: isNew && total > 0,
    );
    liveScore.value = total;
    hint.value = '';

    _spawnSplash(landing.quality);
    final color = switch (landing.quality) {
      LandingQuality.perfect => const Color(0xFF76FF03),
      LandingQuality.good => const Color(0xFFFFFFFF),
      LandingQuality.bellyFlop => const Color(0xFFFF5252),
    };
    world.add(FloatingText(landing.label,
        position: Vector2(diver.position.x, -90), color: color, fontSize: 34, lifetime: 1.6));
    if (landing.quality == LandingQuality.bellyFlop) _shake = 0.4;
  }

  void _spawnSplash(LandingQuality q) {
    final count = switch (q) {
      LandingQuality.perfect => 14,
      LandingQuality.good => 35,
      LandingQuality.bellyFlop => 80,
    };
    final spread = q == LandingQuality.bellyFlop ? 260.0 : 120.0;
    final rnd = math.Random();
    world.add(ParticleSystemComponent(
      position: Vector2(diver.position.x, 0),
      priority: 20,
      particle: Particle.generate(
        count: count,
        lifespan: 1.1,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, gravity * 0.9),
          speed: Vector2((rnd.nextDouble() - 0.5) * spread,
              -150 - rnd.nextDouble() * (q == LandingQuality.perfect ? 120 : 260)),
          position: Vector2((rnd.nextDouble() - 0.5) * 20, 0),
          child: CircleParticle(
            radius: 2.5 + rnd.nextDouble() * 4,
            paint: Paint()
              ..color = Color.lerp(const Color(0xFFFFFFFF), level.waterColor,
                  rnd.nextDouble() * 0.6)!,
          ),
        ),
      ),
    ));
  }

  void _updateCamera(double dt) {
    final target = Vector2(camX, _cameraTargetY());
    final vf = camera.viewfinder;
    vf.position += (target - vf.position) * math.min(1, dt * 6);
    if (_shake > 0) {
      _shake -= dt;
      final r = math.Random();
      vf.position += Vector2((r.nextDouble() - 0.5) * 10, (r.nextDouble() - 0.5) * 10);
    }
  }
}
