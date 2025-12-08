import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:mygame/data/flashcard/database_helper.dart';






class PlayerProfile {
  int? _proficiencyLevel;
  int? _preferredDeckLevel;
  String? _mapFile;
  double? _posX;
  double? _posY;
  int? _hearts;
  int? _xp;
  int? _gold;
  String? _inventoryJson;
  int? _level;
  Map<String, dynamic> _extra = {};

  final int _autosaveSlot = 1;

  static final PlayerProfile instance = PlayerProfile._();

  PlayerProfile._();

  int _baseLevelFloor() => _preferredDeckLevel ?? _proficiencyLevel ?? 1;
  int _currentLevelRaw() => _level ?? _baseLevelFloor();

  int xpToNextLevel(int level) {
    if (level <= 1) return 50;
    return 50 + (level - 1) * 30;
  }

  double xpProgressFraction() {
    final lv = _currentLevelRaw();
    final need = xpToNextLevel(lv);
    final inLevelXp = (_xp ?? 0).clamp(0, need);
    if (need <= 0) return 0;
    final pct = inLevelXp / need;
    return pct.clamp(0.0, 0.99);
  }

  double difficultyScore() {
    final base = _baseLevelFloor();
    final lv = math.max(base, _currentLevelRaw());
    final progress = xpProgressFraction();
    final score = base + (lv - base) + progress;
    return score.clamp(1.0, 99.0);
  }

  int difficultyTier({int maxTier = 10}) {
    return difficultyScore().ceil().clamp(1, maxTier);
  }

  Future<void> init() async {
    try {
      final row = await DatabaseHelper.instance.loadPlayerProfileSlot(_autosaveSlot);
      if (row != null) {
        _proficiencyLevel = (row['proficiency'] as num?)?.toInt();
        _preferredDeckLevel = (row['preferred_deck'] as num?)?.toInt();
        _mapFile = row['map_file'] as String?;
        _posX = (row['pos_x'] as num?)?.toDouble();
        _posY = (row['pos_y'] as num?)?.toDouble();
        _hearts = (row['hearts'] as num?)?.toInt();
        _xp = (row['xp'] as num?)?.toInt();
        _gold = (row['gold'] as num?)?.toInt();
        _inventoryJson = row['inventory'] as String?;
        final extraRaw = row['extra'] as String?;
        if (extraRaw != null && extraRaw.isNotEmpty) {
          try {
            _extra = (jsonDecode(extraRaw) as Map).cast<String, dynamic>();
          } catch (e) {
            debugPrint('PlayerProfile.init extra decode failed: $e');
            _extra = {};
          }
        }
        _level = (_extra['level'] as num?)?.toInt() ??
            _proficiencyLevel ??
            1;
      }
    } catch (e) {

      debugPrint('PlayerProfile.init load failed: $e');
    }
  }

  int? get proficiencyLevel => _proficiencyLevel;
  int? get preferredDeckLevel => _preferredDeckLevel;
  String? get mapFile => _mapFile;
  double? get posX => _posX;
  double? get posY => _posY;
  int? get hearts => _hearts;
  int? get xp => _xp;
  int? get gold => _gold;
  int? get level => _level;

  Future<void> setProficiencyLevel(int level, {bool autosave = true}) async {
    _proficiencyLevel = level;
    _level = level;
    _xp = 0;
    _extra['level'] = level;
    if (autosave) await _autosave();
  }

  Future<void> setPreferredDeckLevel(int level, {bool autosave = true}) async {
    _preferredDeckLevel = level;
    if (autosave) await _autosave();
  }


  Future<void> saveToSlot(int slot) async {
    await DatabaseHelper.instance.savePlayerProfileSlot(
      slot,
      proficiency: _proficiencyLevel,
      preferredDeck: _preferredDeckLevel,
      mapFile: _mapFile,
      posX: _posX,
      posY: _posY,
      hearts: _hearts,
      xp: _xp,
      gold: _gold,
      inventoryJson: _inventoryJson,
      extra: _extra,
    );
  }

  Future<void> loadFromSlot(int slot) async {
    final row = await DatabaseHelper.instance.loadPlayerProfileSlot(slot);
    if (row == null) return;
    _proficiencyLevel = (row['proficiency'] as num?)?.toInt();
    _preferredDeckLevel = (row['preferred_deck'] as num?)?.toInt();
    _mapFile = row['map_file'] as String?;
    _posX = (row['pos_x'] as num?)?.toDouble();
    _posY = (row['pos_y'] as num?)?.toDouble();
    _hearts = (row['hearts'] as num?)?.toInt();
    _xp = (row['xp'] as num?)?.toInt();
    _gold = (row['gold'] as num?)?.toInt();
    _inventoryJson = row['inventory'] as String?;
    final extraRaw = row['extra'] as String?;
    if (extraRaw != null && extraRaw.isNotEmpty) {
      try {
        _extra = (jsonDecode(extraRaw) as Map).cast<String, dynamic>();
      } catch (e) {
        debugPrint('PlayerProfile.loadFromSlot extra decode failed: $e');
        _extra = {};
      }
    }
    _level = (_extra['level'] as num?)?.toInt() ??
        _proficiencyLevel ??
        1;
  }


  Future<void> saveSnapshot({
    String? mapFile,
    double? posX,
    double? posY,
    int? hearts,
    int? xp,
    int? gold,
    String? inventoryJson,
    int slot = 1,
    int? level,
  }) async {
    if (mapFile != null) _mapFile = mapFile;
    if (posX != null) _posX = posX;
    if (posY != null) _posY = posY;
    if (hearts != null) _hearts = hearts;
    if (xp != null) _xp = xp;
    if (gold != null) _gold = gold;
    if (inventoryJson != null) _inventoryJson = inventoryJson;
    if (level != null) _level = level;
    if (_level != null) _extra['level'] = _level;

    await DatabaseHelper.instance.savePlayerProfileSlot(
      slot,
      proficiency: _proficiencyLevel,
      preferredDeck: _preferredDeckLevel,
      mapFile: _mapFile,
      posX: _posX,
      posY: _posY,
      hearts: _hearts,
      xp: _xp,
      gold: _gold,
      inventoryJson: _inventoryJson,
      extra: _extra,
    );
  }

  Future<void> _autosave() async {
    try {
      await saveToSlot(_autosaveSlot);
    } catch (e) {
      debugPrint('PlayerProfile autosave failed: $e');
    }
  }



  int effectiveLevel() {
    return difficultyTier(maxTier: 9999);
  }

  Future<void> setXpLevel(int level, int xp, {bool autosave = true}) async {
    _level = level;
    _xp = xp;
    _extra['level'] = level;
    if (autosave) await _autosave();
  }
}
