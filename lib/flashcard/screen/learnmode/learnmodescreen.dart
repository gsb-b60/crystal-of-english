import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/config/storage.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/learnSpec/allmode.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/learnSpec/learnLevel.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/learnSpec/lessonScreen.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/learnSpec/shufflemode.dart';
import 'package:mygame/flashcard/screen/studymode/echofuse/echofuse.dart';
import 'package:mygame/flashcard/screen/studymode/echomatch/echomath.dart';
import 'package:mygame/flashcard/screen/studymode/echospell/echospell.dart';
import 'package:mygame/flashcard/screen/studymode/meanfuse/meanfuse.dart';
import 'package:mygame/flashcard/screen/studymode/mindfield/mindfeild.dart';
import 'package:mygame/flashcard/screen/studymode/neuropick/neuropick.dart';
import 'package:mygame/flashcard/screen/studymode/phonemix/phonemix.dart';
import 'package:mygame/flashcard/screen/studymode/sound&sight/sound&sight.dart';
import 'package:mygame/flashcard/screen/studymode/wordpulse/wordpulse.dart';
import 'package:mygame/flashcard/screen/studymode/wordsnap/wordsnap.dart';
import 'package:path/path.dart';

class LearnModeScreen extends StatefulWidget {
  const LearnModeScreen({super.key});

  @override
  State<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends State<LearnModeScreen> {
  int index = 0;
  List<Widget> Screens = [
    DailyLearnScreenNav(),

    LevelLearnScreenNav(),
    LearnByMode(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.darkBase,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColor.lightText),
        ),
      ),
      body: Screens[index],
      backgroundColor: AppColor.darkBase,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
          iconSize: 30,
          unselectedItemColor: AppColor.lightText,
          backgroundColor: AppColor.darkBase,
          selectedFontSize: 20,
          unselectedFontSize: 20,
          selectedItemColor: AppColor.greenPrimary,
          enableFeedback: true,
          elevation: 12,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in),
              label: 'Daily Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech),
              label: 'Learn By Levels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz),
              label: 'Learn By Mode',
            ),
          ],
        ),
      ),
    );
  }
}


class LearnByMode extends StatefulWidget {
  const LearnByMode({super.key});

  @override
  State<LearnByMode> createState() => _LearnByModeState();
}

class _LearnByModeState extends State<LearnByMode> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          LearnModeCard(
            co: AppColor.meanFuse,
            line: "Mean Fuse", // meaning - fuse
            screenBuilder: () => Meanfuse(deck_id: 0),
          ),
          LearnModeCard(
            co: AppColor.wordSnap,
            line: "Word Snap", // meaning - other letters
            screenBuilder: () => WordSnap(deck_id: 0,),
          ),
          LearnModeCard(
            co: AppColor.mindField,
            line: "Mind Field", // meaning - shuffle word
            screenBuilder: () => MindFeild(deckID: 0,),
          ),
          LearnModeCard(
            co: AppColor.echoSpell,
            line: "Echo Spell", // ipa+sound - fuse
            screenBuilder: () => Echospell(deck_id: 0),
          ),
          LearnModeCard(
            co: AppColor.echoMatch,
            line: "Echo Match", // ipa+sound - shuffle word
            screenBuilder: () => EchoMatch(deck_id: 0,),
          ),
          LearnModeCard(
            co: AppColor.echoFuse,
            line: "Echo Fuse", // ipa+sound - other letters
            screenBuilder: () => EchoFuse(deck_id: 0,),
          ),
          LearnModeCard(
            co: AppColor.neuroPick,
            line: "Neuro Pick", // picture - fuse
            screenBuilder: () => NeuroPick(deckID: 0,),
          ),
          LearnModeCard(
            co: AppColor.wordPulse,
            line: "Word Pulse", // picture - shuffle word
            screenBuilder: () => WordPulse(deck_id: 0,),
          ),
          LearnModeCard(
            co: AppColor.soundSight,
            line: "Sound and Sight", // picture - arrange letters
            screenBuilder: () => SoundNSight(deck_id: 0,),
          ),
          LearnModeCard(
            co: AppColor.phoneMix,
            line: "Phonemix", // 4 ipa
            screenBuilder: () => PhoneMix(deckID: 0,),
          ),
        ],
      ),
    );
  }
}

class LevelLearnScreenNav extends StatefulWidget {
  const LevelLearnScreenNav({super.key});

  @override
  State<LevelLearnScreenNav> createState() => _LevelLearnScreenNavState();
}

class _LevelLearnScreenNavState extends State<LevelLearnScreenNav> {
  List<Map<String, dynamic>> listLevel = [
    {"level": 1, "co": Color(0xFF7A4A21)}, // Bronze - đồng cổ sang
    {
      "level": 2,
      "co": Color.fromARGB(255, 109, 109, 187),
    }, // Silver - bạc thép đậm
    {"level": 3, "co": Color(0xFFAA7A13)}, // Gold - vàng hoàng gia đậm
    {
      "level": 4,
      "co": Color.fromARGB(255, 112, 148, 255),
    }, // Platinum - xám bạch kim lạnh
    {"level": 5, "co": Color(0xFF0F6F82)}, // Diamond - xanh kim cương sâu
    {"level": 6, "co": Color(0xFFA01717)}, // Master - đỏ quyền lực
    {"level": 7, "co": Color(0xFF351A6E)}, // Challenger - tím đỉnh cao
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 20),
          ...List.generate(
            listLevel.length,
            (i) => LearnModeCard(
              co: listLevel[i]["co"],
              line: "level ${listLevel[i]["level"].toString()}",
              screenBuilder: () => Learnlevel(level: listLevel[i]["level"]),
            ),
          ),
        ],
      ),
    );
  }
}

class DailyLearnScreenNav extends StatelessWidget {
  const DailyLearnScreenNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          LearnModeCard(
            co: AppColor.greenPrimary,
            line: "DAILY LEARN",
            screenBuilder: () => LessonScreen(fetchMode: FetchMode.testing,),
          ),
          LearnModeCard(
            co: AppColor.pinkPrimary,
            line: "ALL MODE",
            screenBuilder: () => AllMode(),
          ),
          LearnModeCard(
            co: AppColor.bluePrimary,
            line: "SHUFFLE MODE",
            screenBuilder: () => Shufflemode(),
          ),
          LearnModeCard(
            co: AppColor.yellowPrimary,
            line: "SupperMemmo 2",
            screenBuilder: () => LessonScreen(fetchMode: FetchMode.SM2,),
          ),
        ],
      ),
    );
  }
}

class LearnModeCard extends StatelessWidget {
  LearnModeCard({
    super.key,
    required this.co,
    required this.line,
    required this.screenBuilder,
  });
  Color co;
  String line;
  Widget Function() screenBuilder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenBuilder()),
        ),
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),

        width: 175,
        decoration: BoxDecoration(
          color: co,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: AlignmentGeometry.bottomCenter,
          child: Text(
            line,
            style: TextStyle(
              color: AppColor.lightText,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
