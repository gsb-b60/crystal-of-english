import 'package:flutter/material.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/data/flashcard/database_helper_io_impl.dart';
class Achievementnoti extends ChangeNotifier{
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _card=[];
  
  bool isLoading=false;
  Future<void> fetchCard()async{
    isLoading=true;
    notifyListeners();
    final data=await _dbhelper.getAllCard();
    _card.clear();
    _card.addAll(data);
    isLoading=false;
    notifyListeners();
  }
  List<Flashcard> getCard()
  {
    if(_card.isEmpty){
      fetchCard();
    }
    return _card; 
  }
}