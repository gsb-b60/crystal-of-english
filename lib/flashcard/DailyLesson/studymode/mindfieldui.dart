import 'package:flutter/material.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/checkBtn.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/choiceBtn.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/progessIndicator.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:provider/provider.dart';


class MindFeildUI extends StatefulWidget {
  const MindFeildUI({super.key});

  @override
  State<MindFeildUI> createState() => _MindFeildUIState();
}

class _MindFeildUIState extends State<MindFeildUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    final options = provider.getOptionList;
    final mean=provider.meaning;
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
              Container(
                height: 150,
                width: 650,
                child: Center(
                  child: Text(
                    mean,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                height: 120,
                width: 750,
                child: Row(
                  children: [
                    ListView.builder(
                      itemCount: options.length,
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
                    SizedBox(width: 50),
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: provider.answered? 0 : -MediaQuery.of(context).size.height,
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



