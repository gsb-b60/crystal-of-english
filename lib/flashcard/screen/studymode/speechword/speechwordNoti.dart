import 'package:flutter/material.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';

class SpeechWordNoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  bool isLoading = false;

  int currentCardIdx = 0;
  bool answered = false;

  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;
  String get word => _cards[currentCardIdx].word ?? "none";
  String get ipa {
    String i = _cards[currentCardIdx].ipa ?? "none";
    if (!i.contains('/')) {
      i = "/${i}/";
    }
    return i;
  }

  Future<void> SetNext() async {
    answered = false;
    currentCardIdx++;
    notifyListeners();
  }

  Future<void> getFlashcardList(int deck_id) async {
    isLoading = true;
    notifyListeners();
    if (deck_id == 0) {
      final data = await DatabaseHelper.instance.getCardLimit(10);
      _cards.clear();
      _cards.addAll(data);
    } else {
      final data = await DatabaseHelper.instance.getCardForDeck(deck_id);
      _cards.clear();
      _cards.addAll(data);
      _cards = _cards
          .where(
            (c) =>
                c.word != null &&
                c.meaning != null &&
                !(c.word?.contains(" ") ?? true),
          )
          .toList();
    }
    isLoading = false;
    notifyListeners();
  }
}
