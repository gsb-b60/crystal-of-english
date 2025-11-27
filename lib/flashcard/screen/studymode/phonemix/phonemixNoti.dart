import 'package:flutter/material.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';
import 'package:mygame/flashcard/DailyLesson/config/storage.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:path/path.dart';

import 'phonemixUI.dart';

class phoneMixNoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  int currentIndex = 0;
  bool isLoading = false;

  List<WordIPA>? options;

  List<String>? listWord;
  List<String>? listIPA;

  int? selectedIPAIDX;
  int? selectedWordIDX;

  List<ButtonState> wordState = List.filled(4, ButtonState.normal);
  List<ButtonState> ipaState = List.filled(4, ButtonState.normal);

  bool answer = false;

  int total=1;
  double get value => (_cards.isEmpty) ? 0 : currentIndex / _cards.length;


  

  void NextTask() {
    options = null;
    listWord = null;
    listIPA = null;
    wordState = List.filled(4, ButtonState.normal);
    ipaState = List.filled(4, ButtonState.normal);
    selectedIPAIDX = null;
    selectedWordIDX = null;
    answer = false;
    notifyListeners();
  }

  void selectWord(int index) {
    if (selectedWordIDX == index) {
      wordState[index] = ButtonState.normal;
      selectedWordIDX = null;
    } else {
      if (selectedWordIDX != null) {
        wordState[selectedWordIDX!] = ButtonState.normal;
      }
      selectedWordIDX = index;
      wordState[index] = ButtonState.selected;
    }
    notifyListeners();
    _checkMath();
  }

  void selectIPA(int index) {
    if (selectedIPAIDX == index) {
      ipaState[index] = ButtonState.normal;
      selectedIPAIDX = null;
    } else {
      if (selectedIPAIDX != null) {
        ipaState[selectedIPAIDX!] = ButtonState.normal;
      }
      selectedIPAIDX = index;
      ipaState[index] = ButtonState.selected;
    }
    notifyListeners();
    _checkMath();
  }
  void _checkMath() {
    if (selectedIPAIDX != null && selectedWordIDX != null) {
      final correctIPA = options!
          .firstWhere((o) => o.word == listWord![selectedWordIDX!])
          .ipa;

      if (correctIPA == listIPA![selectedIPAIDX!]) {
        ipaState[selectedIPAIDX!] = ButtonState.done;
        wordState[selectedWordIDX!] = ButtonState.done;

        selectedWordIDX = null;
        selectedIPAIDX = null;


        answer = !wordState.contains(ButtonState.normal);
        notifyListeners();
      } else {

        ipaState[selectedIPAIDX!] = ButtonState.wrong;
        wordState[selectedWordIDX!] = ButtonState.wrong;
        notifyListeners(); 

        Future.delayed(Duration(milliseconds: 300), () {
          ipaState[selectedIPAIDX!] = ButtonState.normal;
          wordState[selectedWordIDX!] = ButtonState.normal;
          selectedWordIDX = null;
          selectedIPAIDX = null;
          notifyListeners(); 
        });
      }
    }
  }

  Future<void> getFlashcardList(int deckID) async {
    isLoading = true;
    notifyListeners();
    if (deckID == 0) {
      final data = await _dbhelper.getCardLimit(12);
      _cards.clear();
      _cards.addAll(data);
      
    } else {
      final data = await _dbhelper.getCardForDeck(deckID);
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

  List<WordIPA> getOptionList() {
    List<WordIPA> list = [];
    for (
      int i = 0;
      i <= 3 && currentIndex < _cards.length;
      i++, currentIndex++
    ) {
      final currentCard = _cards[currentIndex];
      list.add(
        WordIPA(word: currentCard.word ?? "", ipa: currentCard.ipa ?? ""),
      );
    }
    return list;
  }

  List<WordIPA> setOptionList() {
    options ??= getOptionList();
    return options!;
  }

  List<String> getIPA() {
    if (options != null && listIPA == null) {
      listIPA = options?.map((e) => e.ipa).toList();
      listIPA?.shuffle();
    }
    return listIPA!;
  }

  List<String> getWord() {
    if (options != null && listWord == null) {
      listWord = options?.map((e) => e.word).toList();
      listWord?.shuffle();
    }
    return listWord!;
  }
}