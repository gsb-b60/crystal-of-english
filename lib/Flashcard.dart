import 'package:flutter/material.dart';
import 'database_helper.dart';

class Flashcard {
  final int? id;
  final int deckId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  //fields related fields
  final String? word;
  final String? meaning;
  final String? img;
  final String? sound;
  final String? defSound;
  final String? usageSound;
  final String? example;
  final String? ipa;


  //review related fields
  final int? interval;
  final int? reps;
  final DateTime? due;
  final DateTime? lastReview;
  final int? lapses;
  final double? easeFactor;

  Flashcard({
    this.id,
    required this.deckId,
    this.createdAt,
    this.updatedAt,
    this.word,
    this.meaning,
    this.example,
    this.ipa,
    this.interval,
    this.reps,
    this.due,
    this.lastReview,
    this.lapses,
    this.easeFactor,
    this.img,
    this.sound,
    this.defSound,
    this.usageSound,

  });
  Map<String, dynamic> toMap() {
    return {
      'deck_id': deckId,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'word': word,
      'meaning': meaning,
      'example': example,
      'img':img,
      'ipa': ipa,
      'interval': interval,
      'reps': reps,
      'due': due?.millisecondsSinceEpoch,
      'last_review': lastReview?.millisecondsSinceEpoch,
      'lapses': lapses,
      'ease_factor': easeFactor,
      'sound':sound,
      'defSound':defSound,
      'usageSound':usageSound
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as int?,
      deckId: map['deck_id'] as int,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int):null,
      word: map['word'] as String?,
      meaning: map['meaning'] as String?,
      example: map['example'] as String?,
      ipa: map['ipa'] as String?,
      interval: map['interval'] as int?,
      reps: map['reps'] as int?,
      due: map['due'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due'] as int)
          : null,
      lastReview: map['last_review'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_review'] as int)
          : null,
      lapses: map['lapses'] as int?,
      easeFactor: map['ease_factor'] as double?,
      img: map['img'] as String,
      sound: map['sound'] as String,
      defSound: map['defSound'] as String,
      usageSound: map['usageSound'] as String
    );
  }
}

class Cardmodel with ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  final List<Flashcard> _cards = [];

  String? _media;

  List<Flashcard> get card => _cards;
  String? get media=>_media;
  Future<void> fetchCards(int deckId) async {
    final data = await _dbhelper.getCardForDeck(deckId);
    _cards.clear();
    _cards.addAll(data);
    _media=await _dbhelper.getMediaFile(deckId);
    notifyListeners();
  }

  Future<void> addCard(Flashcard card) async {
    int newId = await _dbhelper.insertCard(card);
    Flashcard newCard = Flashcard(
      id: newId,
      deckId: card.deckId,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
      word: card.word,
      meaning: card.meaning,
      example: card.example,
      img: card.img,
      defSound: card.defSound,
      usageSound: card.usageSound,
      sound: card.sound,
      ipa: card.ipa,
      interval: card.interval,
      reps: card.reps,
      due: card.due,
      lastReview: card.lastReview,
      lapses: card.lapses,
      easeFactor: card.easeFactor,
    );
    _cards.add(newCard);
    notifyListeners();
  }

  Future<void> updateCard(Flashcard card) async {
    await _dbhelper.updateCard(card);
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _cards[index] = card;
    }
    notifyListeners();
  }

  Future<void> deleteCard(int cardId) async {
    await _dbhelper.deleteCard(cardId);
    _cards.removeWhere((c) => c.id == cardId);
    notifyListeners();
  }

  Future<List<Flashcard>> getDueCards(int deckId) async {
    final db = await _dbhelper.database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'deck_id=? and due<=?',
      whereArgs: [deckId, now],
    );
    return List.generate(maps.length, (i) {
      return Flashcard.fromMap(maps[i]);
    });
  }

  Future<void> updateCardAfterReview(
    Flashcard card,
    int performanceRating,
  ) async {
    final newReivewCount = card.reps! + 1;
    late DateTime newDueDate;

    if (performanceRating == 3) {
      newDueDate = DateTime.now().add(const Duration(days: 3));
    } else if (performanceRating == 2) {
      newDueDate = DateTime.now().add(const Duration(days: 2));
    } else if (performanceRating == 1) {
      //newDueDate = DateTime.now().add(const Duration(minutes: 10));
      newDueDate = DateTime.now();
    }

    final updateCard = Flashcard(
      id:card.id!,
      deckId: card.deckId,
      word: card.word,
      meaning: card.meaning,
      due: newDueDate,
      reps: newReivewCount,
    );
    await _dbhelper.updateCard(updateCard);
    //update len db

    //update len du lieu tuc thi
    final index=_cards.indexWhere((c)=>c.id==updateCard.id);
    if(index!=-1)
    {
      _cards[index]=updateCard;
    }
    notifyListeners();
  }
  Future<String?> MediaFile(int deckId) async{
    final String? result= await _dbhelper.getMediaFile(deckId);
    return result;
  }
}       
