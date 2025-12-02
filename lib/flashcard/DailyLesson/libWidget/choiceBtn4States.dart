import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart';

class ChoiceBtnStates extends StatelessWidget {
  ChoiceBtnStates({
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
        height: 50,
        width: 50,
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
              fontSize: 27,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}