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
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'gesture_input.dart';
import 'spin.dart';

enum JumpPhase { ready, charging, flying, landed, finale }

/// Ergebnis eines Sprungs – wird im Ergebnis-Fenster angezeigt.
class JumpResult {
  JumpResult({
    required this.landing,
    required this.floor,
    required this.tricks,
    required this.jumpPoints,
    required this.heightBonus,
    required this.runTotal,
    required this.coins,
    required this.styleBefore,
    required this.styleAfter,
    required this.gameOver,
    required this.highscore,
    required this.newHighscore,
    required this.streak,
    required this.completed,
  });

  final LandingResult landing;
  final int floor;
  final List<Trick> tricks;
  final int jumpPoints;
  final int heightBonus;
  final int runTotal;
  final int coins;
  final int styleBefore;
  final int styleAfter;
  final bool gameOver;
  final int highscore;
  final bool newHighscore;

  /// Gute Landungen in Folge.
  final int streak;

  /// Spiel durchgespielt (10 gute Landungen in Folge).
  final bool completed;
}

/// Endlos-Lauf: Jeder Sprung startet weiter oben. Bruchlandungen kosten
/// Style-Sterne, bei 0 Sternen ist Game Over.
class CliffDiveGame extends FlameGame {
  CliffDiveGame({required this.level, required this.storage, required this.audio})
      : super(camera: CameraComponent.withFixedResolution(width: viewW, height: viewH));

  static const double viewW = 400;
  static const double viewH = 800;
  static const double zoom = 1.2;

  /// Pixel pro Meter.
  static const double ppm = 40;
  static const double gravity = 9.81 * ppm;

  /// Höchstgeschwindigkeit (Luftwiderstand), ca. 55 m/s.
  static const double terminalVelocity = 55 * ppm;

  /// Balkonkante (x) – der Boden liegt bei y = 0.
  static const double edgeX = -60;

  static const int startStyle = 3;

  /// So viele gute Landungen in Folge braucht es zum Durchspielen.
  static const int goalStreak = int.fromEnvironment('GOAL_STREAK', defaultValue: 10);
  static const int maxStyle = 5;

  final JumpLevel level;
  final StorageService storage;
  final AudioService audio;

  late final Diver diver;
  late final PowerMeter powerMeter;
  late final Tower tower;
  final SpinState spin = SpinState();

  // Lauf-Zustand
  late int floor = level.startFloor;
  int style = startStyle;
  int runScore = 0;
  int jumpCount = 0;
  int streak = 0;
  PartyClub? _club;

  JumpPhase phase = JumpPhase.ready;
  double power = 0;
  double _chargeTime = 0;
  double _landedTimer = 0;
  double _shake = 0;
  final List<Trick> performedTricks = [];
  final List<Component> _effects = [];

  final ValueNotifier<int> liveScore = ValueNotifier(0);
  final ValueNotifier<String> hint = ValueNotifier('');

  /// Ändert sich bei Stockwerk/Style – für die Anzeige oben.
  final ValueNotifier<int> hudVersion = ValueNotifier(0);
  JumpResult? lastResult;

  double get topY => -level.heightOf(floor) * ppm;

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
    tower = Tower(edgeX: edgeX, floorHeight: level.floorHeightMeters * ppm);
    world.addAll([
      Clouds(),
      Skyline(factor: 0.93, seed: 1, layer: 0),
      Haze(factor: 0.9),
      Skyline(factor: 0.82, seed: 2, layer: 1),
      tower,
      SmokingMen(wallX: tower.wallX, floorY: -5 * level.floorHeightMeters * ppm),
      Street(curbX: edgeX + 20),
      GroundShadow(),
    ]);
    diver = Diver(character: storage.character, outfit: storage.outfit, style: style);
    world.add(diver);
    powerMeter = PowerMeter()..position = Vector2(viewW - 46, viewH / 2 - 110);
    camera.viewport.add(powerMeter);
    camera.viewfinder.zoom = zoom;
    _prepareJump();
  }

  /// Neuer Lauf ab dem Startstockwerk.
  void newRun() {
    floor = level.startFloor;
    style = startStyle;
    runScore = 0;
    jumpCount = 0;
    streak = 0;
    _prepareJump();
  }

  /// Nächster Sprung, ein paar Stockwerke höher.
  void nextJump() {
    floor += level.floorsPerJump;
    _prepareJump();
  }

  void _prepareJump() {
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
    _club?.removeFromParent();
    _club = null;
    diver.opacity = 1;
    liveScore.value = runScore;
    lastResult = null;
    tower.jumpFloorY = topY;
    diver
      ..character = storage.character
      ..outfit = storage.outfit
      ..style = style
      ..position = Vector2(edgeX - 18, topY - diver.size.y / 2)
      ..angle = 0
      ..velocity.setZero()
      ..snapPose(DiverPose.stand);
    powerMeter
      ..value = 0
      ..visible = true;
    camera.viewfinder.position = _cameraTarget();
    hint.value = 'Finger halten = Kraft aufladen, loslassen = springen';
    hudVersion.value++;
    overlays.remove('result');
  }

  /// Kamera folgt der Figur, zeigt aber nie zu viel vom Boden.
  /// Beim Fallen schaut sie etwas voraus (nach unten).
  Vector2 _cameraTarget() {
    final lookAhead = phase == JumpPhase.flying
        ? (diver.velocity.y * 0.12).clamp(0.0, 140.0)
        : 0.0;
    return Vector2(
      math.max(diver.position.x + 10, -20.0),
      math.min(diver.position.y + lookAhead, -(viewH / 2 / zoom - 130)),
    );
  }

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
    audio.play('whoosh.mp3', volume: 0.7);
  }

  void _jump() {
    phase = JumpPhase.flying;
    final p = power;
    diver.velocity.setValues((1.2 + 2.3 * p) * ppm, -(2.0 + 3.0 * p) * ppm);
    spin.omega = SpinState.jumpSpin;
    diver.pose = DiverPose.air;
    powerMeter.visible = false;
    hint.value = 'Wisch ↑ rückwärts · Wisch ↓ vorwärts · Gegenwischen = bremsen · Tippen = strecken';
    audio.play('jump.mp3', volume: 0.8);
    audio.startWind();
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
      case JumpPhase.finale:
        _updateFinale(dt);
      case JumpPhase.landed:
        _landedTimer += dt;
        if (lastResult?.completed == true) {
          if (_landedTimer > 1.4) _startFinale();
          break;
        }
        if (_landedTimer > 1.6 && !overlays.isActive('result')) {
          overlays.add('result');
          final r = lastResult;
          if (r != null && r.gameOver) {
            audio.play('gameover.mp3');
          } else {
            audio.play('coin.mp3', volume: 0.7);
          }
        }
    }
    _updateCamera(dt);
  }

  void _updateFlight(double dt) {
    diver.velocity.y = math.min(diver.velocity.y + gravity * dt, terminalVelocity);
    diver.position += diver.velocity * dt;

    for (final t in spin.update(dt)) {
      performedTricks.add(t);
      liveScore.value += t.basePoints;
      audio.play('trick.mp3', volume: 0.5);
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
    audio.stopWind();
    // Nur für Tests: --dart-define=DEBUG_PERFECT=true erzwingt saubere Landungen.
    const forcePerfect = bool.fromEnvironment('DEBUG_PERFECT');
    final landing = forcePerfect
        ? const LandingResult(LandingQuality.perfect, 0)
        : LandingJudge.judge(angle: spin.angle, spin: spin.effectiveOmega);
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
        audio.play('land_hero.mp3');
        Future.delayed(const Duration(milliseconds: 450),
            () => audio.voice('whoop', storage.character.voice));
      case LandingQuality.good:
        diver
          ..angle = 0
          ..position.y = -diver.size.y / 2
          ..pose = DiverPose.crouch;
        _dust(x, 16, 90);
        audio.play('land_good.mp3');
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
        audio.play('crash.mp3');
        Future.delayed(const Duration(milliseconds: 350),
            () => audio.voice('hellnah', storage.character.voice));
    }

    final trickPoints = performedTricks.fold<int>(0, (s, t) => s + t.basePoints);
    final heightBonus = landing.quality == LandingQuality.crash ? 0 : floor * 5;
    final jumpPoints = (trickPoints * landing.multiplier).round() + landing.bonus + heightBonus;
    runScore += jumpPoints;
    jumpCount++;

    streak = landing.quality == LandingQuality.crash ? 0 : streak + 1;
    final completed = streak >= goalStreak;
    if (completed) storage.addCompletion();

    final styleBefore = style;
    style = (style + landing.styleChange).clamp(0, maxStyle);
    diver.style = style;
    final gameOver = style == 0;

    final best = storage.highscore(level.id);
    storage.submitScore(level.id, runScore);
    storage.submitFloor(level.id, floor);
    final coins = 5 + jumpPoints ~/ 10;
    storage.addCoins(coins);

    lastResult = JumpResult(
      landing: landing,
      floor: floor,
      tricks: List.of(performedTricks),
      jumpPoints: jumpPoints,
      heightBonus: heightBonus,
      runTotal: runScore,
      coins: coins,
      styleBefore: styleBefore,
      styleAfter: style,
      gameOver: gameOver,
      highscore: math.max(best, runScore),
      newHighscore: runScore > best,
      streak: streak,
      completed: completed,
    );
    liveScore.value = runScore;
    hint.value = '';
    hudVersion.value++;

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

  void _startFinale() {
    phase = JumpPhase.finale;
    diver
      ..angle = 0
      ..position.y = -diver.size.y / 2
      ..pose = DiverPose.walk;
    _club = PartyClub(position: Vector2(diver.position.x + 150, 0));
    world.add(_club!);
    audio.play('cheer.mp3', volume: 0.8);
    hint.value = 'Ab auf die Party!';
  }

  void _updateFinale(double dt) {
    final door = _club!.position.x + PartyClub.doorX;
    if (diver.position.x < door) {
      diver.position.x = math.min(door, diver.position.x + 75 * dt);
    } else {
      diver.opacity = math.max(0, diver.opacity - dt * 2);
      if (diver.opacity == 0 && !overlays.isActive('result')) {
        hint.value = '';
        overlays.add('result');
        audio.play('whoop.mp3');
      }
    }
  }

  void _dust(double x, int count, double spread) {
    final rnd = math.Random();
    _addEffect(ParticleSystemComponent(
      position: Vector2(x, -2),
      priority: 20,
      particle: Particle.generate(
        count: count,
        lifespan: 1.1,
        generator: (i) {
          final dir = rnd.nextBool() ? 1 : -1;
          return AcceleratedParticle(
            acceleration: Vector2(-dir * 60, 10),
            speed: Vector2(dir * (30 + rnd.nextDouble() * spread), -10 - rnd.nextDouble() * 50),
            child: CircleParticle(
              radius: 3 + rnd.nextDouble() * 6,
              paint: Paint()
                ..color = const Color(0x66B5AC9C)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
            ),
          );
        },
      ),
    ));
  }

  void _updateCamera(double dt) {
    final vf = camera.viewfinder;
    final target = _cameraTarget();
    if (phase == JumpPhase.flying) {
      // Im Flug direkt mitgehen, damit sie auch bei hohem Tempo im Bild bleibt.
      final follow = math.min(1.0, dt * 18);
      vf.position += (target - vf.position) * follow;
      final maxOff = Vector2(viewW, viewH) / zoom * 0.3;
      final off = diver.position - vf.position;
      if (off.y.abs() > maxOff.y) vf.position.y = diver.position.y - maxOff.y * off.y.sign;
      if (off.x.abs() > maxOff.x) vf.position.x = diver.position.x - maxOff.x * off.x.sign;
    } else {
      vf.position += (target - vf.position) * math.min(1, dt * 6);
    }
    if (_shake > 0) {
      _shake -= dt;
      final r = math.Random();
      vf.position += Vector2((r.nextDouble() - 0.5) * 10, (r.nextDouble() - 0.5) * 10);
    }
  }

  @override
  void onRemove() {
    audio.stopWind();
    super.onRemove();
  }
}
