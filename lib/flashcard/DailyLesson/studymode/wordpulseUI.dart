import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/lessonNoti.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/choiceBtnVertical.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:provider/provider.dart';

class WordPulseUI extends StatefulWidget {
  const WordPulseUI({super.key});

  @override
  State<WordPulseUI> createState() => _WordPulseUIState();
}

class _WordPulseUIState extends State<WordPulseUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.fetchMedia();
    List<String> options = provider.getOptionList;
    List<bool> states = provider.getOptionStateBool();
    final path = provider.getImagePath();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (path != "")
                    Container(
                      width: 390,
                      height: 270,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(path), fit: BoxFit.cover),
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




