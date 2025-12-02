import 'package:flutter/material.dart';
import 'package:mygame/data/user/userData.dart';

class Questnoti extends ChangeNotifier {
  static final _db = UserDatabase.instance;
  void printHello() {
    print("helloworld");
  }

  Future<void> SetToDB(int rep, int lapse, int cardno) async {
    await _db.UpdateLogDaySuper();
    await _db.UpdateRep(rep);
    await _db.UpdateNoCard(cardno);
    await _db.UpdateLess();
    await _db.UpdateLapse(lapse);
    print(await _db.getUser(1));
  }
}
