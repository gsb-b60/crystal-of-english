import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/choiceBtn4States.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/progessIndicator.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:provider/provider.dart';

class EchospellUI extends StatefulWidget {
  const EchospellUI({super.key});

  @override
  State<EchospellUI> createState() => _EchospellUIState();
}

class _EchospellUIState extends State<EchospellUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.fetchMedia();
    final list = provider.SetUpList();
    final listWord = provider.SetUpListWord();
    final ipa = provider.ipa;
    final listState = provider.GetListState();
    return Scaffold(
      backgroundColor: AppColor.darkBase,
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColor.darkBorder,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: ProgressBar(value: provider.value, inARow: provider.inARow),
        backgroundColor: AppColor.darkBase,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 40),
                  Text(
                    "Tap to build the word.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.outlined(
                    onPressed: () {
                      reader.playSound();
                    },
                    icon: Icon(
                      Icons.volume_up,
                      color: AppColor.lightText,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 30),
                  // Text(
                  //   ipa,
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 40,
                  //     fontWeight: FontWeight.bold,
                  //     fontFamily: 'Roboto',
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(listWord.length, (index) {
                  String value = listWord[index];
                  return Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  );
                }),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,

                children: List.generate(list.length, (index) {
                  final value = list[index];
                  return ChoiceBtnStates(
                    value: value,
                    state: listState[index],
                    onChoose: () {
                      reader.CheckAnswer(value, index);
                    },
                  );
                }),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: provider.answered ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ReviewScreen(
              right: true,
              answer: provider.answer,
              onPressed: () {
                reader.nextCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}



