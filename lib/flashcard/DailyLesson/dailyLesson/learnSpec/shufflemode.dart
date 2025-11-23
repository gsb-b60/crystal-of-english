import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/config/storage.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/timerNoti.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/echofuseUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/echomathUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/echospellUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/meanfuseUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/mindfieldui.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/neuropickUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/phonemixUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/sound&sightUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/wordpulseUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/wordsnapUI.dart';

import 'package:provider/provider.dart';

import '../../screen/endscreen.dart';

class Shufflemode extends StatefulWidget {
  const Shufflemode({super.key});

  @override
  State<Shufflemode> createState() => _ShufflemodeState();
}

class _ShufflemodeState extends State<Shufflemode> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LessonNoti()..getFlashcardListShuffleMode(),
        ),
        ChangeNotifierProvider(create: (context) => TimerNoti()..start()),
      ],

      child: Consumer2<LessonNoti, TimerNoti>(
        builder: (context, provider, timer, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          switch (provider.mode) {
            case StudyMode.soundAndSight:
              return SoundNSightUI();
            case StudyMode.wordsnap:
              return WordSnapUI();
            case StudyMode.echoSpell:
              return EchospellUI();
            case StudyMode.echoMatch:
              return EchoMatchUI();
            case StudyMode.echofuse:
              return EchoFuseUI();
            case StudyMode.mindField:
              return MindFeildUI();
            case StudyMode.neuropick:
              return NeuroPickUI();
            case StudyMode.phonemix:
              return PhoneMixUI();
            case StudyMode.wordpulse:
              return WordPulseUI();
            case StudyMode.EndScreen:
              return EndScreen();
            case StudyMode.meanfuse:
              return MeanfuseUI();
            default:
              return Text("Select a Study Mode");
          }
        },
      ),
    );
  }
}
