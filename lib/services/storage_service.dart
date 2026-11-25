import 'package:shared_preferences/shared_preferences.dart';

/// Speichert Fortschritt lokal auf dem Gerät.
///
/// Falls Speichern nicht möglich ist (z. B. privater Browser-Modus),
/// wird nur für die aktuelle Sitzung im Speicher gemerkt.
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences? _prefs;
  final Map<String, int> _memory = {};

  static Future<StorageService> create() async {
    try {
      return StorageService._(await SharedPreferences.getInstance());
    } catch (_) {
      return StorageService._(null);
    }
  }

  int _getInt(String key) {
    try {
      return _prefs?.getInt(key) ?? _memory[key] ?? 0;
    } catch (_) {
      return _memory[key] ?? 0;
    }
  }

  Future<void> _setInt(String key, int value) async {
    _memory[key] = value;
    try {
      await _prefs?.setInt(key, value);
    } catch (_) {}
  }

  int highscore(String cliffId) => _getInt('highscore_$cliffId');

  /// Speichert den Wert, falls er höher ist. Gibt true zurück bei neuem Rekord.
  Future<bool> submitScore(String cliffId, int score) async {
    if (score <= highscore(cliffId)) return false;
    await _setInt('highscore_$cliffId', score);
    return true;
  }
}
