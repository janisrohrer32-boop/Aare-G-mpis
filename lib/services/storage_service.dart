import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

/// Speichert Fortschritt lokal auf dem Gerät: Münzen, Highscores,
/// gekaufte Figuren/Outfits, Auswahl und Style-Level.
///
/// Falls Speichern nicht möglich ist (z. B. privater Browser-Modus),
/// wird nur für die aktuelle Sitzung im Speicher gemerkt.
class StorageService extends ChangeNotifier {
  StorageService._(this._prefs);

  final SharedPreferences? _prefs;
  final Map<String, Object> _memory = {};

  static Future<StorageService> create() async {
    try {
      return StorageService._(await SharedPreferences.getInstance());
    } catch (_) {
      return StorageService._(null);
    }
  }

  /// Nur für Tests: ohne Gerätespeicher.
  factory StorageService.inMemory() => StorageService._(null);

  T? _get<T>(String key) {
    try {
      final v = _prefs?.get(key);
      if (v is T) return v;
    } catch (_) {}
    final m = _memory[key];
    return m is T ? m : null;
  }

  void _set(String key, Object value) {
    _memory[key] = value;
    try {
      final p = _prefs;
      if (p == null) return;
      if (value is int) p.setInt(key, value);
      if (value is String) p.setString(key, value);
      if (value is List<String>) p.setStringList(key, value);
    } catch (_) {}
  }

  // --- Highscore ---
  int highscore(String levelId) => _get<int>('highscore_$levelId') ?? 0;

  bool submitScore(String levelId, int score) {
    if (score <= highscore(levelId)) return false;
    _set('highscore_$levelId', score);
    notifyListeners();
    return true;
  }

  // --- Münzen ---
  int get coins => _get<int>('coins') ?? 0;

  void addCoins(int amount) {
    _set('coins', coins + amount);
    notifyListeners();
  }

  // --- Style-Level (0 = zerzaust, 5 = glänzend) ---
  static const int maxStyle = 5;
  int get style => _get<int>('style') ?? 3;

  void changeStyle(int delta) {
    _set('style', (style + delta).clamp(0, maxStyle));
    notifyListeners();
  }

  // --- Shop ---
  List<String> _owned(String kind) {
    final l = _get<List<String>>('owned_$kind') ?? <String>[];
    final free = kind == 'char'
        ? Catalog.characters.where((c) => c.price == 0).map((c) => c.id)
        : Catalog.outfits.where((o) => o.price == 0).map((o) => o.id);
    return {...free, ...l}.toList();
  }

  bool ownsCharacter(String id) => _owned('char').contains(id);
  bool ownsOutfit(String id) => _owned('outfit').contains(id);

  CharacterDef get character => Catalog.character(_get<String>('sel_char') ?? 'mia');
  OutfitDef get outfit => Catalog.outfit(_get<String>('sel_outfit') ?? 'sport');

  void selectCharacter(String id) {
    if (!ownsCharacter(id)) return;
    _set('sel_char', id);
    notifyListeners();
  }

  void selectOutfit(String id) {
    if (!ownsOutfit(id)) return;
    _set('sel_outfit', id);
    notifyListeners();
  }

  /// Kauft ein Item, falls genug Münzen da sind. Gibt true bei Erfolg zurück.
  bool buy({required String kind, required String id, required int price}) {
    final owned = _owned(kind);
    if (owned.contains(id) || coins < price) return false;
    _set('coins', coins - price);
    _set('owned_$kind', [...owned, id]);
    notifyListeners();
    return true;
  }
}
