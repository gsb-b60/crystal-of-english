import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';

class EchoFuseNoti extends ChangeNotifier{
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  String media = "";
  bool isLoading = false;
  int currentCardIdx = 0;
  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;
  bool done = false;
  bool right = true;

  List<String>? options;
  List<bool>? states;
  
  int? selectedIndex;
  bool get checkable => selectedIndex != null;
  String get answer => _cards[currentCardIdx].word!;
  String? ipa;
  bool answered = false;


  Future<void> getFlashcardList(int deck_id) async {
    isLoading = true;
    notifyListeners();
    final data = await _dbhelper.getCardForDeck(deck_id);
    media = (await _dbhelper.getMediaFile(deck_id)) ?? "";
    _cards.clear();
    _cards.addAll(data);
    _cards = _cards
        .where(
          (c) =>
              c.sound != null &&
              !(c.word?.contains(" ") ?? true) &&
              c.ipa != null,
        )
        .toList();
    isLoading = false;
    notifyListeners();
  }
  void SetNext() {
    if (currentCardIdx < _cards.length - 1) {
      ipa = null;
      currentCardIdx++;
      options = null;
      answered = false;
      selectedIndex = null;
      notifyListeners();
      right = true;
      notifyListeners();
    }
  }

  String SetIPA() {
    if (ipa == null) {
      ipa = _cards[currentCardIdx].ipa!;
      if (!ipa!.contains('/')) {
        ipa = "/${ipa!}/";
      }
    }
    return ipa!;
  }
  AudioPlayer audioPlayer = AudioPlayer();
  Future<void> playSound() async {
    if (media != "") {
      try {
        await audioPlayer.play(
          DeviceFileSource(
            "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].sound}",
          ),
        );
      } catch (e) {
        print(e);
      }
    }
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
}