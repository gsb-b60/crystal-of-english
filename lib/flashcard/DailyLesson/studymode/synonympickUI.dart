import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/checkBtnVertical.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/choiceBtnVertical.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/progessIndicator.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:provider/provider.dart';

class SynonympickUI extends StatefulWidget {
  const SynonympickUI({super.key});

  @override
  State<SynonympickUI> createState() => _SynonympickUIState();
}

class _SynonympickUIState extends State<SynonympickUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
     provider.fetchMedia();
    List<String> options = provider.getOptionsShuffle;
    List<bool> states = provider.getOptionStateBool();
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
                    "Select the correct answer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (provider.getSynonymPath() != "")
                    Container(
                      width: 390,
                      height: 270,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(provider.getSynonymPath()),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  Container(
                    height: 270,
                    width: 350,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Center(
                                child: ChoiceBtnVertical(
                                  value: options[index],
                                  isSelected: states[index],
                                  onPressed: () {
                                    reader.selectOption(index);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        CheckBtnVertical(
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
