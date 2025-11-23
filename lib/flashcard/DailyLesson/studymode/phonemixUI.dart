import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/lessonNoti.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/choiceBtn4States.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:mygame/flashcard/screen/studymode/phonemix/phonemixNoti.dart';
import 'package:provider/provider.dart';

class PhoneMixUI extends StatefulWidget {
  const PhoneMixUI({super.key});

  @override
  State<PhoneMixUI> createState() => _PhoneMixUIState();
}

class _PhoneMixUIState extends State<PhoneMixUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<phoneMixNoti>();
    final reader = context.read<phoneMixNoti>();
    
    provider.setOptionList();
    final word = provider.getWord();
    final ipa = provider.getIPA();

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
                    "Tap the matching pairs",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                height: 125,
                width: 750,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListView.builder(
                      itemCount: word.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Center(
                          child: ChoiceBtnStates(
                            value: word[index],
                            state:ButtonState.normal ,//provider.wordState[index],
                            onChoose: () {
                              reader.selectWord(index);
                            },
                          ),
                        );
                      },
                    ),
                    
                  ],
                ),
              ),
              SizedBox(width: 50),
              Container(
                height: 125,
                width: 750,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListView.builder(
                      itemCount: ipa.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Center(
                          child: ChoiceBtnStates(
                            value: ipa[index],
                            state:ButtonState.normal,// provider.ipaState[index],
                            onChoose: () {
                              reader.selectIPA(index);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 50),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: provider.answer ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ReviewScreen(
              right: true,
              answer: "",
              onPressed: () {
                reader.NextTask();
              },
            ),
          ),
        ],
      ),
    );
  }
}


