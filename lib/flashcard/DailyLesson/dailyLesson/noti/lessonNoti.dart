import 'dart:io';
import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygame/flashcard/DailyLesson/config/storage.dart';
import 'package:mygame/flashcard/DailyLesson/config/threshold.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';
import 'package:mygame/flashcard/business/supermemo.dart';

enum ButtonState { normal, selected, done, wrong }

class LessonNoti extends ChangeNotifier {
  //data
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  bool isLoading = false;
  int currentCardIdx = 0;
  String media = "";
  Map<int, String> mediaMap = {};
  int currentLessIdx = 0;

  int get cardIdx => SetUpLessonList[currentLessIdx]["cIdx"];
  //data

  double get value =>
      (_cards.isEmpty) ? 0 : currentLessIdx / (SetUpLessonList.length);
  bool get checkable => selectedIndex != null;
  int? selectedIndex;
  int? currentIdx;
  int currentWordIdx = 0;
  bool answered = false;
  bool right = true;
  String get answer => _cards[cardIdx].word!;
  String get meaning => _cards[cardIdx].meaning!;
  String get ipa {
    String i = _cards[cardIdx].ipa!;
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
  List<ButtonState> wordState = List.filled(4, ButtonState.normal);
  List<ButtonState> ipaState = List.filled(4, ButtonState.normal);

  //lession logic
  StudyMode? mode;
  List<Map<String, dynamic>> SetUpLessonList = [
    {"cIdx": 0, "mode": StudyMode.phonemix},
    {"cIdx": 0, "mode": StudyMode.meanfuse},
    {"cIdx": 0, "mode": StudyMode.mindField},
    {"cIdx": 0, "mode": StudyMode.wordsnap},
    {"cIdx": 1, "mode": StudyMode.echoSpell},
    {"cIdx": 1, "mode": StudyMode.echofuse},
    {"cIdx": 1, "mode": StudyMode.echoMatch},
    {"cIdx": 2, "mode": StudyMode.soundAndSight},
    {"cIdx": 2, "mode": StudyMode.neuropick},
    {"cIdx": 2, "mode": StudyMode.wordpulse},
    {"cIdx": 3, "mode": StudyMode.wordsnap},
    {"cIdx": 3, "mode": StudyMode.echoMatch},
    {"cIdx": 3, "mode": StudyMode.meanfuse},
    {"cIdx": 4, "mode": StudyMode.phonemix},
    {"cIdx": 4, "mode": StudyMode.EndScreen},
  ];

  int _acc = 0;
  int inARow = 0;
  void haper() {
    if (inARow > 2) {
      HapticFeedback.vibrate();
    }
  }

  //get variant
  Future<void> getFlashcardList() async {
    isLoading = true;
    notifyListeners();

    final data = await _dbhelper.getCardLimit(10);
    _cards.clear();
    _cards.addAll(data);
    mode = SetUpLessonList[currentLessIdx]["mode"];

    isLoading = false;
    notifyListeners();
  }

  Future<void> getFlashcardListAllMode() async {
    isLoading = true;
    notifyListeners();

    final data = await _dbhelper.getCardLimit(10);
    _cards.clear();
    _cards.addAll(data);
    SetUpLessonList = lessonNotiHelper.allMode;
    mode = SetUpLessonList[currentLessIdx]["mode"];

    isLoading = false;
    notifyListeners();
  }

  Future<void> getFlashcardListShuffleMode() async {
    isLoading = true;
    notifyListeners();

    final data = await _dbhelper.getCardLimit(10);
    _cards.clear();
    _cards.addAll(data);
    SetUpLessonList.shuffle();
    mode = SetUpLessonList[currentLessIdx]["mode"];

    isLoading = false;
    notifyListeners();
  }

  Future<void> getByLevel(int level) async {
    isLoading = true;
    notifyListeners();

    final data = await _dbhelper.getCardByLevel(level);
    _cards.clear();
    _cards.addAll(data);
    _cards = _cards
        .where((c) => c.sound != null && !(c.word?.contains(" ") ?? true))
        .toList();
    mode = SetUpLessonList[currentLessIdx]["mode"];

    isLoading = false;
    notifyListeners();
  }

  String get accuracy {
    int limitedAcc = _acc;
    if (limitedAcc > 7) limitedAcc = 7;
    int percent = 10 - limitedAcc;
    int accuracyPercent = percent * 10;

    return "$accuracyPercent%";
  }

  int get accPercent {
    int limitedAcc = _acc;
    if (limitedAcc > 7) limitedAcc = 7;
    return (10 - limitedAcc) * 10;
  }

  String get accLine => lessonNotiHelper.getAccLine(_acc);

  void updateCard() {
    SMNoti n = SMNoti();
    int rate = right ? 3 : 2;
    n.updateCardAfterReview(_cards[cardIdx], rate);
  }

  void nextCard() {
    updateCard();
    if (currentLessIdx < SetUpLessonList.length) {
      trueList = null;
      listWord = null;
      list = null;
      states = null;
      currentWordIdx = 0;
      answered = false;
      selectedIndex = null;
      options = null;
      statesBool = null;
      currentLessIdx++;
      mode = SetUpLessonList[currentLessIdx]["mode"];
      listWI = null;
      listIPA = null;
      listWordPhone = null;
      selectedIPAIDX = null;
      selectedWordIDX = null;
      wordState = List.filled(4, ButtonState.normal);
      ipaState = List.filled(4, ButtonState.normal);
      notifyListeners();
      right = true;
      notifyListeners();
    }
    print(
      " - current at :${currentLessIdx} - ${SetUpLessonList.length} - is options null ${options == null} -current at mode :${mode}",
    );
  }

  List<String> get getOptionsShuffle {
    options ??= genOptionsShuffle();
    return options!;
  }

  List<String> genOptionsShuffle() {
    List<String> re = lessonNotiHelper.genOptionsShuffleHelp(_cards, cardIdx);
    statesBool = List.generate(re!.length, (_) => false);
    return re;
  }

  String getImagePath() {    
    if (File(
      "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[cardIdx].img}",
    ).existsSync()) {
      return "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[cardIdx].img}";
    }
    return "";
  }

  void CheckAnswer(String letter, int index) {
    if (letter == trueList![currentWordIdx]) {
      states![index] = ButtonState.done;
      listWord![currentWordIdx] = trueList![currentWordIdx];
      notifyListeners();
      currentWordIdx++;
      _acc++;
    } else {
      inARow = 0;
      states![index] = ButtonState.wrong;
      notifyListeners();
      Future.delayed(Duration(milliseconds: 100), () {
        states![index] = ButtonState.normal;
        notifyListeners();
      });
    }
    if (currentWordIdx == list!.length) {
      answered = true;
      haper();
      inARow++;
      notifyListeners();
    }
  }

  List<ButtonState> GetListState() {
    states ??= List.generate(list!.length, (_) => ButtonState.normal);
    return states!;
  }

  List<String> SetUpList() {
    if (list == null) {
      list = _cards[cardIdx].word?.split("");
      trueList = _cards[cardIdx].word!.split("");

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
    if (options?[selectedIndex!] == _cards[cardIdx].word) {
      answered = true;
      inARow++;
      haper();
      notifyListeners();
    } else {
      answered = true;
      right = false;
      _acc++;
      inARow = 0;
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
            "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[cardIdx].sound}",
          ),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  List<bool> getOptionStateBool() {
    statesBool ??= List<bool>.filled(3, false);
    return statesBool!;
  }

  List<String> genOptions() {
    final List<String> strs = [];
    String word = _cards[cardIdx].word!;
    final rand = Random();
    strs.add(word);
    while (strs.length < 3) {
      String mixed;

      if (strs.length == 1) {
        do {
          mixed = generateVariant(word, rand);
        } while (mixed == word || strs.contains(mixed));
      } else {
        // Second distractor: full shuffle
        final letters = word.split('');
        do {
          final shuffled = List.from(letters)..shuffle(rand);
          mixed = shuffled.join('');
        } while (mixed == word || strs.contains(mixed));
      }

      strs.add(mixed);
    }
    List<String> shuffle = List.from(strs)..shuffle(rand);
    statesBool = List.generate(shuffle.length, (_) => false);
    print(shuffle);
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

  Future<String> fetchMedia() async {
    int deck_id = _cards[cardIdx].deckId;
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
  

  List<WordIPA>? listWI;
  List<String>? listIPA;
  List<String>? listWordPhone;
  int? selectedIPAIDX;
  int? selectedWordIDX;
  List<WordIPA> getOptionListPhone() {
    List<WordIPA> list = [];
    List<Flashcard> listCard = _cards.take(4).toList();
    listCard.forEach((c) {
      final currentCard = c;
      list.add(
        WordIPA(word: currentCard.word ?? "", ipa: currentCard.ipa ?? ""),
      );
    });
    list.shuffle();
    return list;
  }

  List<String> getIPA() {
    if (listWI != null && listIPA == null) {
      listIPA = listWI?.map((e) => e.ipa).toList();
      listIPA?.shuffle();
    }
    return listIPA!;
  }

  List<String> getWord() {
    if (listWI != null && listWordPhone == null) {
      listWordPhone = listWI?.map((e) => e.word).toList();
      listWordPhone?.shuffle();
    }
    return listWordPhone!;
  }

  List<WordIPA> setOptionListPhone() {
    listWI ??= getOptionListPhone();
    return listWI!;
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
      final correctIPA = listWI!
          .firstWhere((o) => o.word == listWordPhone![selectedWordIDX!])
          .ipa;

      if (correctIPA == listIPA![selectedIPAIDX!]) {
        ipaState[selectedIPAIDX!] = ButtonState.done;
        wordState[selectedWordIDX!] = ButtonState.done;

        selectedWordIDX = null;
        selectedIPAIDX = null;

        answered = !wordState.contains(ButtonState.normal);
        if(answered)
        {
          haper();
        }
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
}
