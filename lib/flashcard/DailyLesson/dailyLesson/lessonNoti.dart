import 'dart:io';
import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/config/threshold.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';
import 'package:mygame/flashcard/business/supermemo.dart';

enum StudyMode {
  //blankFill,//meaning - arrange letters
  wordsnap, //meaning - other letters
  mindField, //meaning - shuffle word

  echoSpell, //ipa+sound - arrange letters,
  echoMatch, //ipa+sound - shuffle word
  echofuse, //ipa+sound - other letters

  neuropick, //picture - other letters
  wordpulse, //picture - other letters
  soundAndSight, //picture - arrange letters

  phonemix, //4 ipa
  EndScreen,
}

enum ButtonState { normal, selected, done, wrong }

class LessonNoti extends ChangeNotifier {
  //data
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  bool isLoading = false;
  int currentCardIdx = 0;
  String media = "";
  Map<int, String> mediaMap = {};

  //data

  double get value =>
      (_cards.isEmpty) ? 0 : currentCardIdx / (_cards.length - 1);
  bool get checkable => selectedIndex != null;
  int? selectedIndex;
  int? currentIdx;
  int currentWordIdx = 0;
  bool answered = false;
  bool right = true;
  String get answer => _cards[currentCardIdx].word!;
  String get meaning => _cards[currentCardIdx].meaning!;
  String get ipa {
    String i = _cards[currentCardIdx].ipa!;
    if (!i.contains('/')) {
      i = "/$i/";
    }
    return i;
  }

  List<String>? trueList;
  List<String>? list;
  List<String>? listWord;

  //list
  List<ButtonState>? states;
  List<bool>? statesBool;
  List<String>? options;

  //lession logic
  StudyMode? mode;
  List<StudyMode> modes = [
    StudyMode.wordsnap, //meaning - other letters
    StudyMode.mindField, //meaning - shuffle word
    StudyMode.echoSpell, //ipa+sound - arrange letters,
    StudyMode.echoMatch, //ipa+sound - shuffle word
    StudyMode.echofuse, //ipa+sound - other letters
    StudyMode.neuropick, //picture - other letters
    StudyMode.wordpulse, //picture - other letters
    StudyMode.soundAndSight,
    StudyMode.soundAndSight,
    StudyMode.wordsnap, //meaning - other letters
    StudyMode.mindField,
    StudyMode.soundAndSight,
    StudyMode.soundAndSight,
    StudyMode.wordsnap, //meaning - other letters
    StudyMode.mindField,
  ]; //picture - arrange letters];

  int _acc = 0;
  String get accuracy {
    int limitedAcc = _acc;
    if (limitedAcc > 7) limitedAcc = 7;
    int percent = 10 - limitedAcc;
    int accuracyPercent = percent * 10;

    return "$accuracyPercent%";
  }

  String get accLine {
    if (_acc <= ThresholdAcc.excellent) {
      return ThresholdAcc.exStr;
    } else if (_acc <= ThresholdAcc.great) {
      return ThresholdAcc.greatStr;
    } else if (_acc <= ThresholdAcc.good) {
      return ThresholdAcc.okStr;
    } else if (_acc <= ThresholdAcc.fair) {
      return ThresholdAcc.fairStr;
    } else {
      return "POOR"; // optional: điểm quá thấp
    }
  }

  void updateCard() {
    SMNoti n = SMNoti();
    int rate = right ? 3 : 2;
    n.updateCardAfterReview(_cards[currentCardIdx], rate);
  }

  void nextCard() {
    updateCard();
    if (currentCardIdx < _cards.length) {
      print("in < length");
      currentCardIdx++;
      trueList = null;
      listWord = null;
      list = null;
      states = null;
      currentWordIdx = 0;
      answered = false;
      selectedIndex = null;
      options = null;
      statesBool = null;
      mode = modes[currentCardIdx];
      notifyListeners();
      right = true;
      notifyListeners();
    }
    if (currentCardIdx == _cards.length) {
      mode = StudyMode.EndScreen;
    }
    print(
      " - card index :${currentCardIdx} - ${_cards.length} - current at mode :${mode}",
    );
  }

  List<String> get getOptionsShuffle {
    options ??= genOptionsShuffle();
    return options!;
  }

  List<String> genOptionsShuffle() {
    List<String> re = [];
    final answer = _cards[currentCardIdx].word!;

    final otherCards = _cards.where((c) => c.word != answer).toList()
      ..shuffle();

    re = [answer];
    re.addAll(otherCards.take(3 - 1).map((c) => c.word!));

    re.shuffle();
    statesBool = List.generate(re!.length, (_) => false);
    return re;
  }

  String getImagePath() {
    if (File(
      "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].img}",
    ).existsSync()) {
      return "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].img}";
    }
    return "";
  }

  void CheckAnswer(String letter, int index) {
    if (letter == trueList![currentWordIdx]) {
      states![index] = ButtonState.done;
      listWord![currentWordIdx!] = trueList![currentWordIdx!];
      notifyListeners();
      currentWordIdx++;
    } else {
      _acc++;
      states![index] = ButtonState.wrong;
      notifyListeners();
      Future.delayed(Duration(milliseconds: 100), () {
        states![index] = ButtonState.normal;
        notifyListeners();
      });
    }
    if (currentWordIdx == list!.length) {
      answered = true;
      notifyListeners();
    }
  }

  List<ButtonState> GetListState() {
    states ??= List.generate(list!.length, (_) => ButtonState.normal);
    return states!;
  }

  List<String> SetUpList() {
    if (list == null) {
      list = _cards[currentCardIdx].word?.split("");
      trueList = _cards[currentCardIdx].word!.split("");

      if (list!.length > 1) {
        do {
          list!.shuffle();
        } while (listEquals(list, trueList));
      }
    }
    return list!;
  }

  List<String> SetUpListWord() {
    listWord ??= List.filled(list!.length, "_");
    return listWord!;
  }

  void checkAnswerMC() {
    if (options?[selectedIndex!] == _cards[currentCardIdx].word) {
      answered = true;
      notifyListeners();
    } else {
      answered = true;
      right = false;
      _acc++;
      notifyListeners();
    }
  }

  void selectOption(int index) {
    if (selectedIndex == null) {
      selectedIndex = index;
      statesBool?[index] = true;
    } else {
      statesBool?[selectedIndex!] = false;
      selectedIndex = index;
      statesBool?[index] = true;
    }

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

  List<bool> getOptionStateBool() {
    statesBool ??= List<bool>.filled(genOptions().length, false);
    return statesBool!;
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
    statesBool = List.generate(shuffle.length, (_) => false);
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

  //function
  Future<void> getFlashcardList() async {
    isLoading = true;
    notifyListeners();
    final data = await _dbhelper.getAllCard();
    _cards.clear();
    _cards.addAll(data);
    _cards = _cards
        .where(
          (c) =>
              c.sound != null &&
              !(c.word?.contains(" ") ?? true) &&
              c.ipa != null &&
              c.img != null &&
              c.meaning != null,
        )
        .take(10)
        .toList();
    print(_cards.length);
    mode = modes[currentCardIdx];
    isLoading = false;
    notifyListeners();
  }

  Future<String> fetchMedia() async {
    int deck_id = _cards[currentCardIdx].deckId;
    if (mediaMap.containsKey(deck_id)) {
      media = mediaMap[deck_id] ?? "";
      return mediaMap[deck_id]!;
    } else {
      String md = await _dbhelper.getMediaFile(deck_id) ?? "";
      mediaMap[deck_id] = md;
      media = mediaMap[deck_id] ?? "";
      return md;
    }
  }
}
