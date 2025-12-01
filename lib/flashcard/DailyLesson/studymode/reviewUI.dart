import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';

class ReviewUI extends StatefulWidget {
  const ReviewUI({super.key});

  @override
  State<ReviewUI> createState() => _ReviewUIState();
}

class _ReviewUIState extends State<ReviewUI> {
  final controller = SwipableStackController();
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader= context.read<LessonNoti>();
    List<Flashcard> list=provider.card3;
    return Scaffold(
      backgroundColor: AppColor.darkBase,
      body: Stack(
        children: [
          SwipableStack(
            onSwipeCompleted: (index, direction) => {
              if(index==list.length-1)
              {
                reader.callDone()
              }
            },
            controller: controller,
            overlayBuilder: (context, properties) {
              final opacity = min(properties.swipeProgress, 1.0);

              switch (properties.direction) {
                case SwipeDirection.up:
                  return Opacity(
                    opacity: opacity,
                    child: CardLabel(
                      color: Colors.redAccent,
                      right: true,
                      value: "Hard",
                    ),
                  );
                case SwipeDirection.down:
                  return Opacity(
                    opacity: opacity,
                    child: CardLabel(
                      color: Colors.teal,
                      right: false,
                      value: "easy",
                    ),
                  );
                default:
                  return Text(SwipeDirection.values.toString());
              }
            },
            detectableSwipeDirections: const {
              SwipeDirection.up,
              SwipeDirection.down,
            },
            builder: (context, properties) {
              int index=(properties.index)% list.length;
              return SizedBox.expand(
                child: FlipCard(
                  direction: FlipDirection.VERTICAL,
                  front: Card(
                    color: AppColor.darkBase,
                    child: Center(
                      child: Text(
                        list[index].word??"",
                        style: TextStyle(
                          color: AppColor.lightText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  back: Card(
                    color: AppColor.darkBase,
                    child: Center(
                      child: Container(
                        width: 400,
                        child: Text(
                          list[index].meaning??"",
                          style: TextStyle(
                            color: AppColor.lightText,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center
                        ),
                      ),
                    ),
                  ),
                  onFlipDone: (isFront) {
                    // if (isFront) {
                    //   backKey.currentState?.playSound(
                    //     widget.media!,
                    //     widget.card?.sound ?? '',
                    //   );
                    // }
                  },
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.next(swipeDirection: SwipeDirection.up);
                    },
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColor.redAccent,
                        borderRadius: BorderRadius.circular(12),
                        border: BoxBorder.all(
                          color: AppColor.redPrimary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "HARD",
                        style: TextStyle(
                          color: AppColor.lightText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      controller.rewind();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColor.bluePrimary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.refresh,
                        size: 30,
                        color: AppColor.lightText,
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      controller.next(swipeDirection: SwipeDirection.down);
                    },
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColor.primaryTeal,
                        borderRadius: BorderRadius.circular(12),
                        border: BoxBorder.all(
                          color: AppColor.accentTeal,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "EASY",
                        style: TextStyle(
                          color: AppColor.lightText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

class CardLabel extends StatelessWidget {
  final Color color;
  final bool right;
  final String value;
  const CardLabel({
    super.key,
    required this.color,
    required this.right,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: right ? Alignment.bottomCenter : Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.all(50.0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
