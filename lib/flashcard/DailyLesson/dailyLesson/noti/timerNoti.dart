import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/config/threshold.dart';
import 'package:mygame/data/user/userBusiness.dart';


class TimerNoti extends ChangeNotifier {
  final userBiz = UserBusiness();
  final stopWatch = Stopwatch();
  Duration? elapse;
  void start() {
    stopWatch.start();
  }

  Future<void> stop() async{
    stopWatch.stop();
    elapse = stopWatch.elapsed;
    stopWatch.reset();
    await userBiz.AddStudyTime(elapse??Duration(seconds: 10));
  }

  Duration get time => elapse ?? Duration(seconds: 180);
  String get formatted =>
      "${elapse!.inMinutes}:${(elapse!.inSeconds % 60).toString().padLeft(2, '0')}";

  String get getThresholdString {
    Duration elapsed = elapse ?? Duration(seconds: 180);
    if (elapsed <= ThresholdTime.Super) {
      return ThresholdTime.SuperStr;
    } else if (elapsed <= ThresholdTime.Quick) {
      return ThresholdTime.QuickStr;
    } else if (elapsed <= ThresholdTime.Moderate) {
      return ThresholdTime.ModerateStr;
    } else {
      return ThresholdTime.SlowStr;
    }
  }
}
