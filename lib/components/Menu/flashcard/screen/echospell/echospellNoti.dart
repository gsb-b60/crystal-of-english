import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/business/Flashcard.dart';
import 'package:mygame/components/Menu/flashcard/data/database_helper.dart';

class EchospellNoti extends ChangeNotifier{
  static final _dbhelper=DatabaseHelper.instance;
  List<Flashcard> _cards=[];
  bool isLoading=false;
  Future<void> getFlashcardList(int deck_id)async
  {
    isLoading=true;
    notifyListeners();
    final data= await _dbhelper.getCardForDeck(deck_id);
    _cards.clear();
    _cards.addAll(data);

    _cards=_cards.where((c)=>c.sound!=null&&!(c.word?.contains(" ")??true)).toList();
    isLoading=false;
    notifyListeners();
  }
}