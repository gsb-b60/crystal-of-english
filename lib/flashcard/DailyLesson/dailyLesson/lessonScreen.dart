import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/lessonNoti.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/timerNoti.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/echofuseUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/echomathUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/echospellUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/mindfieldui.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/neuropickUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/phonemixUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/sound&sightUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/wordpulseUI.dart';
import 'package:mygame/flashcard/DailyLesson/studymode/wordsnapUI.dart';
import 'package:mygame/components/Menu/Theme/color.dart';


import 'package:provider/provider.dart';

import '../screen/endscreen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
       providers: [
        ChangeNotifierProvider(create: (context) => LessonNoti()..getFlashcardList(),),
        ChangeNotifierProvider(create: (context)=>TimerNoti()..start())
       ],
      
      child: Consumer2<LessonNoti,TimerNoti>(
        builder: (context, provider,timer, _) {
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
            default:
              return Text("Select a Study Mode");
          }
        },
      ),
    );
  }
}

