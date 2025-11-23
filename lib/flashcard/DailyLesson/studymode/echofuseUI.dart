import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/lessonNoti.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/checkBtn.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/choiceBtn.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:provider/provider.dart';

class EchoFuseUI extends StatefulWidget {
  const EchoFuseUI({super.key});

  @override
  State<EchoFuseUI> createState() => _EchoFuseUIState();
}

class _EchoFuseUIState extends State<EchoFuseUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.fetchMedia();
    final ipa = provider.ipa;
    final options = provider.getOptionsShuffle;
    final states = provider.getOptionStateBool();
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
        title: LinearProgressIndicator(
          value: provider.value,
          backgroundColor: AppColor.darkCard,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.greenPrimary),
          minHeight: 18,
          borderRadius: BorderRadius.circular(9),
        ),
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
                    "Select the correct answer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                        Text(
                          ipa,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 150,
                      width: 750,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ListView.builder(
                            itemCount: 3, //options.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Center(
                                child: ChoiceBtn(
                                  value: options[index],
                                  isSelected: states[index],
                                  onPressed: () {
                                    reader.selectOption(index);
                                  },
                                ),
                              );
                            },
                          ),
                          CheckBtn(
                            isChecked: provider.checkable,
                            onCheck: () {
                              reader.checkAnswerMC();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
              right: provider.right,
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




