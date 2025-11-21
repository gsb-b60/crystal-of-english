import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';
import 'package:mygame/flashcard/screen/sound&sight/sound&sightUI.dart';

class SoundNSightNoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  String media = "";
  bool isLoading = false;

  int currentCardIdx = 0;
  int currentIndex = 0;
  List<String>? list;
  List<String>? listWord;
  List<String> trueList=[];
  List<ButtonState>? listState;
  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;

  bool answered = false;
  
  void SetNext() {
    trueList.clear();
    listWord = null;
    list = null;
    listState = null;
    currentIndex = 0;
    answered = false;
    currentCardIdx++;
    notifyListeners();
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

  Future<void> getFlashcardList(int deck_id) async {
    isLoading = true;
    notifyListeners();
    final data=await _dbhelper.getCardForDeck(  deck_id);
    _cards.clear();
    _cards.addAll(data);
    _cards=_cards.where((c) => c.sound!=null && !(c.word?.contains(" ")?? true)&&c.img!=null).toList();
    media = (await _dbhelper.getMediaFile(deck_id)) ?? "";
    isLoading = false;
    notifyListeners();
  }
  List<String> getList()
  {
    if(list==null)
    {
      list??=_cards[currentCardIdx].word!.split("");
      trueList.clear();
      trueList.addAll(list!);
      listWord=List.generate(list!.length, (index) => "_");
      list!.shuffle();
    }
    return list!;
  }
  List<String> getListWord()
  {
    listWord ??= List.generate(_cards[currentCardIdx].word!.length, (index) => "_");
    return listWord!;
  }
  List<ButtonState> getListState()
  {
    listState ??= List.filled(_cards[currentCardIdx].word!.length, ButtonState.normal);
    return listState!;
  }
  String getImagePath()
  {
    if(File("/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].img}").existsSync())
    {
      return "/data/user/0/com.example.mygame/app_flutter/anki/$media/${_cards[currentCardIdx].img}";
    }
    return "";
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
}