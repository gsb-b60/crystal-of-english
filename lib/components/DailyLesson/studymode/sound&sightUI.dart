import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mygame/components/DailyLesson/dailyLesson/lessonNoti.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
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
                              return ChoiceBtn(
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

class ChoiceBtn extends StatelessWidget {
  ChoiceBtn({
    super.key,
    required this.value,
    required this.state,
    required this.onChoose,
  });

  String value;
  ButtonState state;
  VoidCallback onChoose;
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColor.darkBase;
    Color textColor = Colors.white;
    Color borderColor = AppColor.darkCard;

    switch (state) {
      case ButtonState.selected:
        backgroundColor = AppColor.darkSurface;
        borderColor = AppColor.BlueMuted;
        textColor = AppColor.BlueMuted;
        break;
      case ButtonState.done:
        backgroundColor = AppColor.darkBase;
        borderColor = AppColor.darkCard;
        textColor = AppColor.darkerCard;
        break;
      case ButtonState.normal:
        backgroundColor = AppColor.darkBase;
        borderColor = AppColor.darkCard;
        textColor = Colors.white;
        break;
      case ButtonState.wrong:
        backgroundColor = AppColor.darkSurface;
        borderColor = AppColor.redMuted;
        textColor = AppColor.redMuted;
        break;
    }
    return GestureDetector(
      onTap: () {
        if (state != ButtonState.done) {
          onChoose.call();
        }
      },
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: BoxBorder.all(color: borderColor, width: 4),
          color: backgroundColor,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 35,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  ReviewScreen({super.key, required this.onPressed});
  VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: Container(
          color: AppColor.darkSurface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  SizedBox(width: 30),
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColor.greenBright,
                    size: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Great job!",
                    style: TextStyle(
                      color: AppColor.greenBright,
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  SizedBox(
                    width: 650,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        onPressed.call();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColor.greenPrimary,
                      ),
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(
                          color: AppColor.darkBase,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            bottom: BorderSide(
                              color: AppColor.greenAccent,

                              width: 6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
