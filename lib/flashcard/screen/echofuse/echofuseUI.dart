import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/screen/echofuse/echofuseNoti.dart';
import 'package:provider/provider.dart';

class EchoFuseUI extends StatefulWidget {
  const EchoFuseUI({super.key});

  @override
  State<EchoFuseUI> createState() => _EchoFuseUIState();
}

class _EchoFuseUIState extends State<EchoFuseUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EchoFuseNoti>();
    final reader = context.read<EchoFuseNoti>();
    final ipa = provider.SetIPA();

    final options = provider.getOptions();
    final states = provider.getOptionState();
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
                              reader.checkAnswer(provider.selectedIndex!);
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
                reader.SetNext();
              },
            ),
          ),
        ],
      ),
    );
  }
}
class ChoiceBtn extends StatelessWidget {
  String value;
  bool isSelected;
  VoidCallback? onPressed;
  ChoiceBtn({
    super.key,
    required this.isSelected,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 150,
        height: 70,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: isSelected ? AppColor.greenMuted : AppColor.darkCard,
              width: 4,
            ),
            backgroundColor: isSelected
                ? AppColor.darkSurface
                : AppColor.darkBase,
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? AppColor.greenMuted : Colors.white,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class CheckBtn extends StatelessWidget {
  bool isChecked;
  VoidCallback? onCheck;
  CheckBtn({super.key, required this.isChecked, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isChecked ? onCheck : null,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: 70,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            bottom: BorderSide(
              color: isChecked ? AppColor.greenAccent : Colors.transparent,
              width: 6,
            ),
          ),
          color: isChecked ? AppColor.greenPrimary : AppColor.darkCard,
        ),
        child: Center(
          child: Text(
            "Check",
            style: TextStyle(
              color: AppColor.darkBase,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  ReviewScreen({
    super.key,
    required this.right,
    required this.onPressed,
    required this.answer,
  });
  final bool right;
  final String answer;

  VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: right ? 250 : 350,
        child: Container(
          color: AppColor.darkSurface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  SizedBox(width: 30),
                  Icon(
                    right ? Icons.check_circle_rounded : Icons.cancel,
                    color: right ? AppColor.greenBright : AppColor.redPrimary,
                    size: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    right ? "Great job!" : "Incorrect",
                    style: TextStyle(
                      color: right ? AppColor.greenBright : AppColor.redPrimary,
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              if (!right)
                Row(
                  children: [
                    SizedBox(width: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Correct answer:",
                          style: TextStyle(
                            color: AppColor.redPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          answer,
                          style: TextStyle(
                            color: AppColor.redAccent,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                        elevation: right ? 10 : 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: right
                            ? AppColor.greenPrimary
                            : AppColor.redBright,
                      ),
                      child: Text(
                        right ? "CONTINUE" : "GOT IT",
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
                              color: right
                                  ? AppColor.greenAccent
                                  : AppColor.redMuted,
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
