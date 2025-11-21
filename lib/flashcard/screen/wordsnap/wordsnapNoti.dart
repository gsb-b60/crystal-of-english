import 'package:flutter/material.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';

class WordSnapNoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  bool IsLoading = false;
  int currentCardIdx = 0;
  int? selectedIndex;
  List<String>? options;
  List<bool>? states;
  double get value => currentCardIdx / _cards.length;
  String get mean=> _cards[currentCardIdx].meaning!;
  bool get checkable=> selectedIndex != null;

  bool answered = false;
  bool right=true;

  String get answer=>_cards[currentCardIdx].word!;


  Future<void> getFlashcardList(int deckID) async {
    IsLoading = true;
    notifyListeners();
    final data = await DatabaseHelper.instance.getCardForDeck(deckID);
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
    IsLoading = false;
    notifyListeners();
  }
  List<String> genOptions() {
    if (options == null) {
      final answer = _cards[currentCardIdx].word!;

      final otherCards = _cards.where((c) => c.word != answer).toList()
        ..shuffle();

      options = [answer];
      options?.addAll(otherCards.take(3 - 1).map((c) => c.word!));

      options?.shuffle();
      states = List.generate(options!.length, (_) => false);
    }
    return options!;
  }
  List<bool> getOptionState() {
    states ??= List<bool>.filled(genOptions().length, false);
    return states!;
  }
  void selectOption(int index) {
    if (selectedIndex == null) {
      selectedIndex = index;
      states?[index] = true;
    }else{
      states?[selectedIndex!] = false;
      selectedIndex = index;
      states?[index] = true;
    }

    notifyListeners();
  }
  void checkAnswer(int selectedIndex) {
    if (options?[selectedIndex] == _cards[currentCardIdx].word) {
      answered = true;
      notifyListeners();
    }
    else{
      answered = true;
      right=false;
      notifyListeners();
    }
  }
  void nextCard() {
    if (currentCardIdx < _cards.length - 1) {
      currentCardIdx++;
      options = null;
      answered = false;
      selectedIndex = null;
      notifyListeners();
      right=true;
      notifyListeners();
    }

  }
}
