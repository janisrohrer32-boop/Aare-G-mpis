import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/foundation.dart';

import '../components/city.dart';
import '../components/diver.dart';
import '../components/floating_text.dart';
import '../components/power_meter.dart';
import '../models/landing.dart';
import '../models/level.dart';
import '../models/trick.dart';
import '../services/storage_service.dart';
import 'gesture_input.dart';
import 'spin.dart';

enum JumpPhase { ready, charging, flying, landed }

/// Ergebnis eines Sprungs – wird im Ergebnis-Fenster angezeigt.
class RunResult {
  RunResult({
    required this.landing,
    required this.tricks,
    required this.trickPoints,
    required this.total,
    required this.highscore,
    required this.newHighscore,
    required this.coins,
    required this.styleBefore,
    required this.styleAfter,
  });

  final LandingResult landing;
  final List<Trick> tricks;
  final int trickPoints;
  final int total;
  final int highscore;
  final bool newHighscore;
  final int coins;
  final int styleBefore;
  final int styleAfter;
}

class CliffDiveGame extends FlameGame {
  CliffDiveGame({required this.level, required this.storage})
      : super(camera: CameraComponent.withFixedResolution(width: viewW, height: viewH));

  static const double viewW = 400;
  static const double viewH = 800;

  /// Pixel pro Meter.
  static const double ppm = 40;
  static const double gravity = 9.81 * ppm;

  /// Balkonkante (x) – der Boden liegt bei y = 0.
  static const double edgeX = -60;

  final JumpLevel level;
  final StorageService storage;

  late final Diver diver;
  late final PowerMeter powerMeter;
  final SpinState spin = SpinState();

  JumpPhase phase = JumpPhase.ready;
  double power = 0;
  double _chargeTime = 0;
  double _landedTimer = 0;
  double _shake = 0;
  final List<Trick> performedTricks = [];
  final List<Component> _effects = [];

  final ValueNotifier<int> liveScore = ValueNotifier(0);
  final ValueNotifier<String> hint = ValueNotifier('');
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
      Skyline(factor: 0.92, seed: 1, color: const Color(0xFFA9B6C8), windowColor: const Color(0x33FFFFFF)),
      Skyline(factor: 0.8, seed: 2, color: const Color(0xFF7D8BA0), windowColor: const Color(0x55FFE0A0)),
      Tower(edgeX: edgeX, topY: topY, floorHeight: 3 * ppm),
      Street(curbX: edgeX + 20),
    ]);
    diver = Diver(character: storage.character, outfit: storage.outfit, style: storage.style);
    world.add(diver);
    powerMeter = PowerMeter()..position = Vector2(viewW - 46, viewH / 2 - 110);
    camera.viewport.add(powerMeter);
    camera.viewfinder.zoom = zoom;
    reset();
  }

  /// Alles zurück auf den Balkon.
  void reset() {
    phase = JumpPhase.ready;
    power = 0;
    _chargeTime = 0;
    _shake = 0;
    spin.reset();
    performedTricks.clear();
    for (final e in _effects) {
      e.removeFromParent();
    }
    _effects.clear();
    liveScore.value = 0;
    lastResult = null;
    diver
      ..character = storage.character
      ..outfit = storage.outfit
      ..style = storage.style
      ..position = Vector2(edgeX - 18, topY - diver.size.y / 2)
      ..angle = 0
      ..velocity.setZero()
      ..snapPose(DiverPose.stand);
    powerMeter
      ..value = 0
      ..visible = true;
    camera.viewfinder.position = _cameraTarget();
    hint.value = 'Finger halten = Kraft aufladen, loslassen = springen';
    overlays.remove('result');
  }

  static const double zoom = 1.2;

  /// Kamera folgt der Figur, zeigt aber nie zu viel vom Boden.
  Vector2 _cameraTarget() => Vector2(
        (diver.position.x + 10).clamp(-20.0, 300.0),
        math.min(diver.position.y, -(viewH / 2 / zoom - 130)),
      );

  // ---------------- Eingabe ----------------

  void _onHoldStart() {
    if (phase != JumpPhase.ready) return;
    phase = JumpPhase.charging;
    _chargeTime = 0;
    diver.pose = DiverPose.crouch;
    hint.value = 'Loslassen zum Springen!';
  }

  void _onHoldEnd() {
    if (phase != JumpPhase.charging) return;
    _jump();
  }

  void _onTap() {
    if (phase != JumpPhase.flying) return;
    spin.stretched = !spin.stretched;
  }

  void _onSwipe(SwipeDirection dir) {
    if (phase != JumpPhase.flying) return;
    switch (dir) {
      case SwipeDirection.up:
        spin.push(-1);
      case SwipeDirection.down:
        spin.push(1);
      default:
        return;
    }
  }

  void _jump() {
    phase = JumpPhase.flying;
    final p = power;
    diver.velocity.setValues((1.2 + 2.3 * p) * ppm, -(2.0 + 3.0 * p) * ppm);
    spin.omega = SpinState.jumpSpin;
    diver.pose = DiverPose.air;
    powerMeter.visible = false;
    hint.value = 'Wisch ↑ rückwärts · Wisch ↓ vorwärts · Gegenwischen = bremsen · Tippen = strecken';
  }

  // ---------------- Spiel-Schleife ----------------

  @override
  void update(double dt) {
    super.update(dt);
    switch (phase) {
      case JumpPhase.ready:
        break;
      case JumpPhase.charging:
        _chargeTime += dt;
        power = (1 - math.cos(_chargeTime * math.pi * 1.2)) / 2;
        powerMeter.value = power;
      case JumpPhase.flying:
        _updateFlight(dt);
      case JumpPhase.landed:
        _landedTimer += dt;
        if (_landedTimer > 1.4 && !overlays.isActive('result')) overlays.add('result');
    }
    _updateCamera(dt);
  }

  void _updateFlight(double dt) {
    diver.velocity.y += gravity * dt;
    diver.position += diver.velocity * dt;

    for (final t in spin.update(dt)) {
      performedTricks.add(t);
      liveScore.value += t.basePoints;
      _addEffect(FloatingText(t.name,
          position: diver.position + Vector2(0, -60), color: const Color(0xFFFFEB3B)));
      _addEffect(FloatingText('+${t.basePoints}',
          position: diver.position + Vector2(0, -30), fontSize: 22));
    }
    diver.angle = spin.angle;
    diver.pose = spin.stretched
        ? DiverPose.stretch
        : (spin.effectiveOmega.abs() > 3 ? DiverPose.tuck : DiverPose.air);

    if (diver.position.y >= -diver.size.y / 2) _land();
  }

  void _addEffect(Component c) {
    _effects.add(c);
    world.add(c);
  }

  void _land() {
    phase = JumpPhase.landed;
    _landedTimer = 0;
    diver.velocity.setZero();
    final landing = LandingJudge.judge(angle: spin.angle, spin: spin.effectiveOmega);
    final x = diver.position.x;

    switch (landing.quality) {
      case LandingQuality.perfect:
        diver
          ..angle = 0
          ..position.y = -diver.size.y / 2
          ..pose = DiverPose.hero;
        _addEffect(Cracks(position: Vector2(x + 4, 1), big: true));
        _dust(x, 30, 140);
        _shake = 0.25;
      case LandingQuality.good:
        diver
          ..angle = 0
          ..position.y = -diver.size.y / 2
          ..pose = DiverPose.crouch;
        _dust(x, 16, 90);
      case LandingQuality.crash:
        var a = spin.angle % (2 * math.pi);
        if (a > math.pi) a -= 2 * math.pi;
        final side = a >= 0 ? 1.0 : -1.0;
        diver
          ..angle = side * math.pi / 2
          ..position.y = -9
          ..snapPose(DiverPose.sprawl);
        _addEffect(DizzyStars(position: Vector2(x + side * 30, -26)));
        _dust(x, 40, 200);
        _shake = 0.4;
    }

    final trickPoints = performedTricks.fold<int>(0, (s, t) => s + t.basePoints);
    final total = (trickPoints * landing.multiplier).round() + landing.bonus;
    final best = storage.highscore(level.id);
    storage.submitScore(level.id, total);
    final coins = 5 + total ~/ 10;
    storage.addCoins(coins);
    final styleBefore = storage.style;
    storage.changeStyle(landing.styleChange);
    diver.style = storage.style;

    lastResult = RunResult(
      landing: landing,
      tricks: List.of(performedTricks),
      trickPoints: trickPoints,
      total: total,
      highscore: math.max(best, total),
      newHighscore: total > best && total > 0,
      coins: coins,
      styleBefore: styleBefore,
      styleAfter: storage.style,
    );
    liveScore.value = total;
    hint.value = '';

    final color = switch (landing.quality) {
      LandingQuality.perfect => const Color(0xFF76FF03),
      LandingQuality.good => const Color(0xFFFFFFFF),
      LandingQuality.crash => const Color(0xFFFF5252),
    };
    final label = FloatingText(landing.label,
        position: Vector2(viewW / 2, viewH * 0.4), color: color, fontSize: 30, lifetime: 1.8);
    _effects.add(label);
    camera.viewport.add(label);
  }

  void _dust(double x, int count, double spread) {
    final rnd = math.Random();
    _addEffect(ParticleSystemComponent(
      position: Vector2(x, -2),
      priority: 20,
      particle: Particle.generate(
        count: count,
        lifespan: 0.9,
        generator: (i) {
          final dir = rnd.nextBool() ? 1 : -1;
          return AcceleratedParticle(
            acceleration: Vector2(-dir * 60, 20),
            speed: Vector2(dir * (30 + rnd.nextDouble() * spread), -10 - rnd.nextDouble() * 50),
            child: CircleParticle(
              radius: 3 + rnd.nextDouble() * 5,
              paint: Paint()..color = const Color(0x88B0A898),
            ),
          );
        },
      ),
    ));
  }

  void _updateCamera(double dt) {
    final vf = camera.viewfinder;
    vf.position += (_cameraTarget() - vf.position) * math.min(1, dt * 6);
    if (_shake > 0) {
      _shake -= dt;
      final r = math.Random();
      vf.position += Vector2((r.nextDouble() - 0.5) * 10, (r.nextDouble() - 0.5) * 10);
    }
  }
}
