import 'dart:io';
import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';

class WordPulseNoti extends ChangeNotifier {
    static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  String media = "";
  bool isLoading = false;

  int currentCardIdx = 0;

  String? ipa;
  List<String>? options;
  List<bool>? states;

  int currentIndex = 0;
  bool answered = false;
  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;

  bool done = false;
  bool right = true;
  int? selectedIndex;
  bool get checkable => selectedIndex != null;
  String get answer => _cards[currentCardIdx].word!;

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
    isLoading = false;
    notifyListeners();
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

  Future<void> SetNext() async{
    if (currentCardIdx < _cards.length - 1) {
      ipa = null;
      currentCardIdx++;
      options = null;
      answered = false;
      selectedIndex = null;
      media=(await DatabaseHelper.instance.getMediaFile(_cards[currentCardIdx].deckId))!;
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

  List<String> genOptions() {
    final List<String> options = [];
    String word = _cards[currentCardIdx].word!;
    final rand = Random();
    options.add(word);
    while (options.length < 3) {
      String mixed;

      if (options.length == 1) {
        // First distractor: slight variant
        do {
          mixed = generateVariant(word, rand);
        } while (mixed == word || options.contains(mixed));
      } else {
        // Second distractor: full shuffle
        final letters = word.split('');
        do {
          final shuffled = List.from(letters)..shuffle(rand);
          mixed = shuffled.join('');
        } while (mixed == word || options.contains(mixed));
      }

      options.add(mixed);
    }
    List<String> shuffle = List.from(options)..shuffle(rand);
    states = List.generate(shuffle.length, (_) => false);
    return shuffle;
  }

  String generateVariant(String word, Random rand) {
    if (word.length < 2) return word;

    final chars = word.split('');

    int i = rand.nextInt(chars.length);
    int j = rand.nextInt(chars.length);

    if (i == j) j = (j + 1) % chars.length;

    final temp = chars[i];
    chars[i] = chars[j];
    chars[j] = temp;

    return chars.join('');
  }

  List<String> get getOptionList {
    options ??= genOptions();
    return options!;
  }

  List<bool> GetListState() {
    states ??= List.generate(options!.length, (_) => false);
    return states!;
  }

  void selectOption(int index) {
    if (selectedIndex == null) {
      selectedIndex = index;
      states?[index] = true;
    } else {
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
    } else {
      answered = true;
      right = false;
      notifyListeners();
    }
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