import 'package:flutter/material.dart';
import 'package:mygame/components/DailyLesson/lessonNoti.dart';
import 'package:mygame/components/DailyLesson/studymode/echofuseUI.dart';
import 'package:mygame/components/DailyLesson/studymode/echomathUI.dart';
import 'package:mygame/components/DailyLesson/studymode/echospellUI.dart';
import 'package:mygame/components/DailyLesson/studymode/mindfieldui.dart';
import 'package:mygame/components/DailyLesson/studymode/neuropickUI.dart';
import 'package:mygame/components/DailyLesson/studymode/phonemixUI.dart';
import 'package:mygame/components/DailyLesson/studymode/sound&sightUI.dart';
import 'package:mygame/components/DailyLesson/studymode/wordpulseUI.dart';
import 'package:mygame/components/DailyLesson/studymode/wordsnapUI.dart';

import 'package:provider/provider.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LessonNoti()..getFlashcardList(),
      child: Consumer<LessonNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          switch(provider.mode){
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
            default:
              return Text("Select a Study Mode");
          }
        },
      ),
    );
  }
}
