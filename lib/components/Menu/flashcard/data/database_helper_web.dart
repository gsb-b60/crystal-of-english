import 'package:mygame/components/Menu/flashcard/business/Deck.dart';
import 'package:mygame/components/Menu/flashcard/business/Flashcard.dart';

// Web stub: in-memory store for demo purposes
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  final List<Deck> _decks = <Deck>[];
  final Map<int, List<Flashcard>> _cards = <int, List<Flashcard>>{};
  int _nextDeckId = 1;
  int _nextCardId = 1;

  Future<int> insertDeck(Deck deck) async {
    final d = Deck(id: _nextDeckId++, name: deck.name, description: deck.description, media: deck.media);
    _decks.add(d);
    return d.id!;
  }

  Future<List<Deck>> getDecks() async {
    return List<Deck>.from(_decks);
  }

  Future<void> deleteDeck(int id) async {
    _decks.removeWhere((d) => d.id == id);
    _cards.remove(id);
  }

  Future<List<Flashcard>> getCardForDeck(int deckId) async {
    return List<Flashcard>.from(_cards[deckId] ?? const <Flashcard>[]);
  }




  Future<void> updateCard(Flashcard card) async {}
  Future<void> deleteCard(int cardId) async {}

  Future<int> insertCard(Flashcard card) async {
    final c = Flashcard(
      id: _nextCardId++,
      deckId: card.deckId,
      word: card.word,
      meaning: card.meaning,
      example: card.example,
      img: card.img,
      ipa: card.ipa,
      interval: card.interval,
      reps: card.reps,
      due: card.due,
      lastReview: card.lastReview,
      lapses: card.lapses,
      easeFactor: card.easeFactor,
      sound: card.sound,
      defSound: card.defSound,
      usageSound: card.usageSound,
      complexity: card.complexity,
      synonyms: card.synonyms,
    );
    _cards.putIfAbsent(card.deckId, () => <Flashcard>[]).add(c);
    return c.id!;
  }

  Future<String?> pickApkgFile() async => null;
  Future<String?> pickAndCopyFile() async => '';
  Future<String?> unzipApkgFile(String apkgFilePath) async => null;
  Future<dynamic> CreateUnZipFolder() async => null;
  Future<dynamic> CreateDeckFolder() async => null;
  Future<void> importDataFromAnki(String ankiDbPath) async {}
  Future<void> processCardForDeck(dynamic a, int b, int c) async {}
  Future<String> MoveMediaFile() async => '';
  Future<String?> getMediaFile(int deckID) async => null;

  // Player profile (web in-memory)
  final Map<int, Map<String, Object?>> _profiles = {};

  Future<void> savePlayerProfileSlot(
    int slot, {
    int? proficiency,
    int? preferredDeck,
    String? mapFile,
    double? posX,
    double? posY,
    int? hearts,
    int? xp,
    int? gold,
    String? inventoryJson,
    Map<String, dynamic>? extra,
  }) async {
    _profiles[slot] = {
      'slot': slot,
      'proficiency': proficiency,
      'preferred_deck': preferredDeck,
      'map_file': mapFile,
      'pos_x': posX,
      'pos_y': posY,
      'hearts': hearts,
      'xp': xp,
      'gold': gold,
      'inventory': inventoryJson,
      'extra': extra == null ? null : extra.toString(),
      'saved_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<Map<String, Object?>?> loadPlayerProfileSlot(int slot) async {
    return _profiles[slot];
  }

  Future<List<Map<String, Object?>>> listPlayerProfileSlots() async {
    return _profiles.entries
        .map((e) => Map<String, Object?>.from(e.value))
        .toList(growable: false);
  }

  Future<void> deletePlayerProfileSlot(int slot) async {
    _profiles.remove(slot);
  }
}

