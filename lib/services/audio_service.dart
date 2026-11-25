import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Musik und Soundeffekte. Fehler beim Abspielen (z. B. wenn der Browser
/// Ton noch blockiert) werden ignoriert – das Spiel läuft dann stumm weiter.
class AudioService extends ChangeNotifier {
  AudioService({bool muted = false}) : _muted = muted; // ignore: prefer_initializing_formals

  static const effects = [
    'jump.mp3',
    'whoosh.mp3',
    'wind.mp3',
    'trick.mp3',
    'land_hero.mp3',
    'land_good.mp3',
    'crash.mp3',
    'coin.mp3',
    'gameover.mp3',
    'hellnah.mp3',
    'whoop.mp3',
  ];

  bool _muted;
  bool _musicStarted = false;
  AudioPlayer? _wind;

  bool get muted => _muted;

  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll([...effects, 'music.mp3']);
    } catch (_) {}
  }

  /// Startet die Hintergrundmusik (nach dem ersten Antippen erlaubt).
  Future<void> startMusic() async {
    if (_muted || _musicStarted) return;
    _musicStarted = true;
    try {
      await FlameAudio.bgm.play('music.mp3', volume: 0.45);
    } catch (_) {
      _musicStarted = false;
    }
  }

  void toggleMute() {
    _muted = !_muted;
    try {
      if (_muted) {
        FlameAudio.bgm.stop();
        _musicStarted = false;
        stopWind();
      } else {
        startMusic();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> play(String name, {double volume = 1}) async {
    if (_muted) return;
    try {
      await FlameAudio.play(name, volume: volume);
    } catch (_) {}
  }

  Future<void> startWind() async {
    if (_muted || _wind != null) return;
    try {
      _wind = await FlameAudio.loop('wind.mp3', volume: 0.35);
    } catch (_) {}
  }

  void stopWind() {
    try {
      _wind?.stop();
      _wind?.dispose();
    } catch (_) {}
    _wind = null;
  }
}
