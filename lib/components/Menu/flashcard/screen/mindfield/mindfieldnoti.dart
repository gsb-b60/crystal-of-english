import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/business/Flashcard.dart';
import 'package:mygame/components/Menu/flashcard/data/database_helper_io_impl.dart';

class Mindfieldnoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  final List<Flashcard> _cards = [];
  bool IsLoading = false;
  int currentIndex = 0;
  List<String>? options;

  Flashcard get currentCard => _cards[currentIndex];
  List<Flashcard> get cards => _cards;
  bool get Isloading => IsLoading;

  Future<void> getFlashcardList(int deckID) async {
    IsLoading = true;
    notifyListeners();
    final data = await _dbhelper.getCardForDeck(deckID);
    _cards.clear();
    _cards.addAll(data);
    IsLoading = false;
    notifyListeners();
  }

  void nextCard() {
    if (currentIndex < _cards.length - 1) {
      currentIndex++;
      options=null;
      notifyListeners();
    }
  }
  double getProgress()
  {
    return currentIndex/cards.length;
  }

  List<String> genOptions() {
    final List<String> options =[];
    String word = currentCard.word!;
    final letters = word.split('');
    final rand = Random();
    options.add(word);
    while (options.length < 3) {
      List<String> shuffled = List.from(letters)..shuffle(rand);
      String mixed = shuffled.join('');
      options.add(mixed);
    }
    List<String> shuffle = List.from(options)..shuffle(rand);
    return shuffle;
  }
  List<String> get getOptionList{
    options ??= genOptions();
    return options!;
  }
  bool checkAnswer(int selectedIndex){
    return options![selectedIndex]==currentCard.word;
  }

}
