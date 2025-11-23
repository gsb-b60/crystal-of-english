import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/learnSpec/allmode.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/learnSpec/lessonScreen.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/learnSpec/shufflemode.dart';
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

    Text('Index 1: Business', style: TextStyle(color: AppColor.greenFade)),
    Text('Index 2: School', style: TextStyle(color: AppColor.greenFade)),
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

class DailyLearnScreenNav extends StatelessWidget {
  const DailyLearnScreenNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonScreen()),
              ),
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 25, horizontal: 20),

              width: 175,
              decoration: BoxDecoration(
                color: AppColor.greenPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: Text(
                  "Learn Daily",
                  style: TextStyle(
                    color: AppColor.lightText,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllMode()),
              ),
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 25, horizontal: 20),

              width: 175,
              decoration: BoxDecoration(
                color: AppColor.pinkPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: Text(
                  "All Mode",
                  style: TextStyle(
                    color: AppColor.lightText,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Shufflemode()),
              ),
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 25, horizontal: 20),

              width: 175,
              decoration: BoxDecoration(
                color: AppColor.bluePrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: Text(
                  "SHUFFLE MODE",
                  style: TextStyle(
                    color: AppColor.lightText,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
