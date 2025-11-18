import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/business/Flashcard.dart';
import 'package:mygame/components/Menu/flashcard/data/database_helper_io_impl.dart';

class NeuroPickNoti extends ChangeNotifier {
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
    final data = await _dbhelper.getCardForDeck(deck_id);
    media=await _dbhelper.getMediaFile(deck_id);
    _cards.clear();
    _cards.addAll(data);
    _cards = _cards
        .where(
          (card) =>
              card.word != null &&
              card.img != null &&
              !(card.word?.contains(" ") ?? true),
        )
        .toList();
    isLoading = false;
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
    if(File("/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].img}").existsSync())
    {
      return "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].img}";
    }
    return "";
  }
}
