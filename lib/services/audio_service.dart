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
    'hellnah_m.mp3',
    'whoop_m.mp3',
    'hellnah_a.mp3',
    'whoop_a.mp3',
    'cheer.mp3',
  ];

  bool _muted;
  bool _musicStarted = false;
  String track = 'music_boombap.mp3';
  AudioPlayer? _wind;

  bool get muted => _muted;

  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll(effects);
    } catch (_) {}
  }

  /// Startet die Hintergrundmusik (nach dem ersten Antippen erlaubt).
  Future<void> startMusic() async {
    if (_muted || _musicStarted) return;
    _musicStarted = true;
    try {
      await FlameAudio.bgm.play(track, volume: 0.45);
    } catch (_) {
      _musicStarted = false;
    }
  }

  /// Wechselt den Soundtrack (spielt sofort, falls Musik läuft).
  Future<void> setTrack(String file) async {
    if (file == track) return;
    track = file;
    if (_musicStarted) {
      try {
        await FlameAudio.bgm.stop();
      } catch (_) {}
      _musicStarted = false;
      await startMusic();
    }
  }

  /// Spruch bei der Landung, passend zur Figur ('f', 'm' oder 'a').
  void voice(String line, String who) =>
      play(who == 'f' ? '$line.mp3' : '${line}_$who.mp3');

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
