import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygame/data/user/user.dart';
import 'package:mygame/data/user/userData.dart';

class QuestNoti extends ChangeNotifier {
  //data
  UserDatabase _database = UserDatabase.instance;
  late User _user;
  bool isLoading=false;
  Future<void> getUser() async {
    isLoading=true;
    notifyListeners();
    _user = await _database.getUser(1);
    print(_user);
    isLoading=false;
    notifyListeners();
  }

  //quest
  int LessGoal = 2;
  int RepGoad = 20;
  int LearnGoal = 30;
  int QuestGoal=20;

  double get lessVal {
    return (_user.TotalLess ?? 1) / LessGoal;
  }

  double get repVal {
    return (_user.Rep ?? 1) / RepGoad;
  }

  double get learnVal {
    return (_user.TotalCard ?? 1) / LearnGoal;
  }
  double get questVal{
    return (_user.QuestPoint??1)/QuestGoal;
  }
  String get questPoint=>(_user.QuestPoint??0).toString();

  //time
  int get remaining {
    int re = 24 - DateTime.now().hour;
    return re;
  }

  int get remainingdate {
    final now = DateTime.now();
    final firstOfNextMonth = (now.month < 12)
        ? DateTime(now.year, now.month + 1, 1)
        : DateTime(now.year + 1, 1, 1);

    return firstOfNextMonth.difference(now).inDays;
  }

  String get month {
    final now = DateTime.now();
    final monthName = DateFormat.MMMM().format(now);
    print(monthName); // e.g., "November"
    return monthName;
  }
}
  // List<String> quests = [
  //   "learn 10 lesson",
  //   "meet 5 level 5 word",
  //   "meet echo fuse 10 time",
  //   "learn without a mistake",
  //   "fast learner <25 S",
  //   "working bee: learn 50 quizz",
  //   "success leanr 5 words level 5",
  //   "meet new 10 word",
  // ];