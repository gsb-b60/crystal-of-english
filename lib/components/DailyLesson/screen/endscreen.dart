import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:mygame/components/DailyLesson/dailyLesson/lessonNoti.dart';
import 'package:mygame/components/DailyLesson/dailyLesson/timerNoti.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:provider/provider.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timer=context.watch<TimerNoti>();
    final reader=context.read<TimerNoti>();
    reader.stop();
    final elipse=timer.formatted;

    final less=context.watch<LessonNoti>();
    return Scaffold(
      backgroundColor: AppColor.darkBase,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Lesson complete!",
            style: TextStyle(
              color: AppColor.yellowPrimary,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnalystWidget(value: "25",ico: Icons.bolt,co: AppColor.yellowPrimary,line:"TOTAL XP" ,),
              AnalystWidget(value: less.accuracy,ico: Icons.my_location,co: AppColor.greenPrimary,line:less.accLine ,),
              AnalystWidget(value: elipse,ico: Icons.timer,co: AppColor.bluePrimary,line:timer.getThresholdString ,),
            ],
          ),
          GestureDetector(
            onTap: () => {Navigator.pop(context)},
            child: Container(
              width: 470,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColor.bluePrimary,
              ),
              child: Center(
                child: Text(
                  "Claim XP",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalystWidget extends StatelessWidget {
  AnalystWidget({
    super.key,
    required this.value,
    required this.ico,
    required this.co,
    required this.line
  });
  final String line;
  final String value;
  final IconData ico;
  final Color co;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 120,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: co,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            line,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 80,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColor.darkBase,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  ico,
                  color: co,
                  size: 30,
                ),
                Text(
                  value,
                  style: TextStyle(
                    color:co,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
