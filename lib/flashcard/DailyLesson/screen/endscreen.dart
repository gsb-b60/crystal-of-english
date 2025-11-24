import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/timerNoti.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:provider/provider.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerNoti>();
    final reader = context.read<TimerNoti>();
    reader.stop();
    final elipse = timer.formatted;

    final less = context.watch<LessonNoti>();
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
              AnalystWidget(
                co: AppColor.yellowPrimary,
                line: "TOTAL XP",
                list: [
                  Icon(Icons.bolt, color: AppColor.yellowPrimary, size: 30),
                  Text(
                    "25",
                    style: TextStyle(
                      color: AppColor.yellowPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AnalystWidget(
                co: AppColor.greenPrimary,
                line: less.accLine,
                list: [
                  Icon(
                    Icons.my_location,
                    color: AppColor.greenPrimary,
                    size: 30,
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: less.accPercent.toDouble()),
                    duration: Duration(seconds: 2),
                    builder: (context, value, child) {
                      final current = "${value.toInt()} %";
                      return Text(
                        current,
                        style: TextStyle(
                          color: AppColor.greenPrimary,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  // Text(
                  //   less.accuracy,
                  //   style: TextStyle(
                  //     color: AppColor.greenPrimary,
                  //     fontSize: 40,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
              AnalystWidget(
                co: AppColor.bluePrimary,
                line: timer.getThresholdString,
                list: [
                  Icon(Icons.timer, color: AppColor.bluePrimary, size: 30),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: timer.time.inSeconds.toDouble(),
                    ),
                    duration: const Duration(
                      seconds: 2,
                    ), // tốc độ chạy animation
                    builder: (context, value, child) {
                      final current = Duration(seconds: value.toInt());
                      final mm = current.inMinutes
                          .remainder(60)
                          .toString()
                          .padLeft(2, "0");
                      final ss = current.inSeconds
                          .remainder(60)
                          .toString()
                          .padLeft(2, "0");

                      return Text(
                        "$mm:$ss",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColor.bluePrimary,
                        ),
                      );
                    },
                  ),
                ],
              ),
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
    required this.co,
    required this.line,
    required this.list,
  });
  final String line;
  final Color co;
  List<Widget> list;
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
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
              children: list,
            ),
          ),
        ],
      ),
    );
  }
}
