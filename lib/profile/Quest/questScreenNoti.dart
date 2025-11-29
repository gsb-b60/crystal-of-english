import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygame/data/user/user.dart';
import 'package:mygame/data/user/userData.dart';

enum ClaimState { claimed, claimable, unclaimed }

class QuestNoti extends ChangeNotifier {
  //data
  UserDatabase _database = UserDatabase.instance;
  late User _user;
  bool isLoading = false;
  Future<void> getUser() async {
    isLoading = true;
    notifyListeners();
    _user = await _database.getUser(1);
    print(_user);
    isLoading = false;
    notifyListeners();
  }
  //crud test data

  //quest
  int LessGoal = 2;
  int RepGoal = 20;
  int LearnGoal = 30;
  int QuestGoal = 20;

  int get lessP {
    return (_user.IndayLess ?? 1);
  }

  int get repP {
    return (_user.Rep ?? 1);
  }

  int get cardP {
    return (_user.IndayCard ?? 1);
  }

  double get lessVal {
    return (_user.IndayLess ?? 1) / LessGoal;
  }

  double get repVal {
    return (_user.Rep ?? 1) / RepGoal;
  }

  double get learnVal {
    return (_user.IndayCard ?? 1) / LearnGoal;
  }

  double get questVal {
    return (_user.QuestPoint ?? 1) / QuestGoal;
  }

  String get questPoint => (_user.QuestPoint ?? 0).toString();

  //claim logic
  ClaimState ex = ClaimState.unclaimed;
  ClaimState get lessClaim {
    if (_user.IsLessClaim ?? false) {
      return ClaimState.claimed;
    }
    if (lessVal >= 1) {
      return ClaimState.claimable;
    }
    return ClaimState.unclaimed;
  }

  ClaimState get learnClaim {
    if (_user.IsLearnClaim ?? false) {
      return ClaimState.claimed;
    }
    if (learnVal >= 1) {
      return ClaimState.claimable;
    }
    return ClaimState.unclaimed;
  }

  ClaimState get repClaim {
    if (_user.IsRepClaim ?? false) {
      return ClaimState.claimed;
    }
    if (repVal >= 1) {
      return ClaimState.claimable;
    }
    return ClaimState.unclaimed;
  }

  Future<void> ClaimLess() async {
    await _database.UpdateClaimLess();
    await _database.UpdateQuestPoint();
    _user.IsLessClaim = true;
    _user.QuestPoint = (_user.QuestPoint ?? 0) + 1;
    notifyListeners();
  }

  Future<void> ClaimLearn() async {
    await _database.UpdateClaimLearn();
    await _database.UpdateQuestPoint();
    _user.IsLearnClaim = true;
    _user.QuestPoint = (_user.QuestPoint ?? 0) + 1;
    notifyListeners();
  }

  Future<void> ClaimRep() async {
    await _database.UpdateClaimRep();
    await _database.UpdateQuestPoint();
    _user.IsRepClaim = true;
    _user.QuestPoint = (_user.QuestPoint ?? 0) + 1;
    notifyListeners();
  }

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