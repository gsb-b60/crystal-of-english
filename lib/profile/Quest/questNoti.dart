import 'package:flutter/material.dart';

class QuestNoti extends ChangeNotifier {
  List<String> quests = [
    "learn 10 lesson",
    "meet 5 level 5 word",
    "meet echo fuse 10 time",
    "learn without a mistake",
    "fast learner <25 S",
    "working bee: learn 50 quizz",
    "success leanr 5 words level 5",
    "meet new 10 word",
  ];
  double get value => 2 / 20;
}
