/// Simple in-memory player profile used to synchronize placement, deck level,
/// and enemy spawn difficulty.
///
/// NOTE: This implementation is intentionally in-memory to avoid adding
/// platform-dependent plugin dependencies. If you want persistence later,
/// we can switch to `shared_preferences` or a DB and enable platform plugins.
class PlayerProfile {
  int? _proficiencyLevel;
  int? _preferredDeckLevel;

  static final PlayerProfile instance = PlayerProfile._();

  PlayerProfile._();

  /// Initialize (no-op for in-memory implementation).
  Future<void> init() async {
    // no-op: no persisted state available in this build
    return Future.value();
  }

  int? get proficiencyLevel => _proficiencyLevel;
  int? get preferredDeckLevel => _preferredDeckLevel;

  Future<void> setProficiencyLevel(int level) async {
    _proficiencyLevel = level;
    return Future.value();
  }

  Future<void> setPreferredDeckLevel(int level) async {
    _preferredDeckLevel = level;
    return Future.value();
  }

  /// Returns effective level to use for difficulty decisions.
  /// Priority: preferredDeckLevel (if set) -> proficiencyLevel -> default 1
  int effectiveLevel() {
    return _preferredDeckLevel ?? _proficiencyLevel ?? 1;
  }
}
