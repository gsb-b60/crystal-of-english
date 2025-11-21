import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/data/flashcard/database_helper.dart';
import 'package:mygame/flashcard/screen/echospell/echospellUI.dart';

class EchospellNoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  String media = "";
  bool isLoading = false;

  int currentCardIdx = 0;

  String? ipa;
  List<String>? trueList;
  List<String>? list;
  List<String>? listWord;
  List<ButtonState>? listState;
  int currentIndex = 0;
  bool answered = false;
  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;

  bool done = false;

  Future<void> getFlashcardList(int deck_id) async {
    isLoading = true;
    notifyListeners();
    final data = await _dbhelper.getCardForDeck(deck_id);
    media = (await _dbhelper.getMediaFile(deck_id)) ?? "";
    _cards.clear();
    _cards.addAll(data);

    _cards = _cards
        .where((c) => c.sound != null && !(c.word?.contains(" ") ?? true))
        .toList();
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

  void CheckAnswer(String letter, int index) {
    if (letter == trueList![currentIndex]) {
      listState![index] = ButtonState.done;
      listWord![currentIndex] = trueList![currentIndex];
      notifyListeners();
      currentIndex++;
    } else {
      listState![index] = ButtonState.wrong;
      notifyListeners();
      Future.delayed(Duration(milliseconds: 100), () {
        listState![index] = ButtonState.normal;
        notifyListeners();
      });
    }
    if (currentIndex == list!.length) {
      answered = true;
      notifyListeners();
    }
  }

  void SetNext() {
    ipa = null;
    trueList = null;
    listWord = null;
    list = null;
    listState = null;
    currentIndex = 0;
    answered = false;
    currentCardIdx++;
    notifyListeners();
  }

  // void SetUpList()
  // {
  //   if(list!=null)
  //   {

  //   }
  //   if(listWord!=null)
  //   {

  //   }
  // }
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

  String SetIPA() {
    if (ipa == null) {
      ipa = _cards[currentCardIdx].ipa!;
      if (!ipa!.contains('/')) {
        ipa = "/${ipa!}/";
      }
    }
    return ipa!;
  }

  List<ButtonState> GetListState() {
    listState ??= List.generate(list!.length, (_) => ButtonState.normal);
    return listState!;
  }
}
