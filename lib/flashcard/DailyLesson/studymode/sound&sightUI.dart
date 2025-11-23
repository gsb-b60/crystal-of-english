import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/lessonNoti.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/choiceBtn4States.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:provider/provider.dart';

class SoundNSightUI extends StatefulWidget {
  const SoundNSightUI({super.key});

  @override
  State<SoundNSightUI> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SoundNSightUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.fetchMedia();
    List<String> list = provider.SetUpList();
    List<String> listWord = provider.SetUpListWord();
    List<ButtonState> listState = provider.GetListState();
    String img = provider.getImagePath();

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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 30),
                      if (img != "")
                        Container(
                          width: 350,
                          height: 270,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(img), fit: BoxFit.cover),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
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
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 170,
                        width: 400,
                        child: Center(
                          child: Wrap(
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
                        ),
                      ),
                    ],
                  ),
                ],
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
              answer: "",
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



