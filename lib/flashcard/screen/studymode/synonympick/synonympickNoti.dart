

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';

class SynonympickNoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  String? media;
  int currentCardIdx = 0;

  List<String>? options;
  List<bool>? states;

  bool isLoading = false;
  bool answered = false;
  bool right=true;
  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;
  bool get checkable=> selectedIndex != null;
  String get answer=>_cards[currentCardIdx].word!;
  int? selectedIndex;

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
    media=(await DatabaseHelper.instance.getMediaFile(_cards[0].deckId))!;
    isLoading=false;
    notifyListeners();
  }

  List<String> getOptions() {
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
    states ??= List<bool>.filled(getOptions().length, false);
    return states!;
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

  Future<void> nextCard() async{
    if (currentCardIdx < _cards.length - 1) {
      currentCardIdx++;
      options = null;
      answered = false;
      selectedIndex = null;
      media=(await DatabaseHelper.instance.getMediaFile(_cards[currentCardIdx].deckId))!;
      notifyListeners();
      right=true;
      notifyListeners();
    }

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
  String getImagePath()
  {
    if(File("/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].synonyms}").existsSync())
    {
      return "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].synonyms}";
    }
    return "";
  }
}
