import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';

class PhoneMixUI extends StatefulWidget {
  const PhoneMixUI({super.key});

  @override
  State<PhoneMixUI> createState() => _PhoneMixUIState();
}

class WordIPA {
  final String word;
  final String ipa;
  WordIPA({required this.word, required this.ipa});
}

class _PhoneMixUIState extends State<PhoneMixUI> {
  int? selectedIndex;
  int? selectedWordIDX;
  int? selectedIPAIDX;
  bool right = true;
  bool answered = false;
  List<WordIPA> options = [
    WordIPA(word: "one", ipa: "/wʌn/"),
    WordIPA(word: "two", ipa: "/tuː/"),
    WordIPA(word: "three", ipa: "/θriː/"),
    WordIPA(word: "four", ipa: "/fɔːr/"),
  ];
  List<String> word = [];
  List<String> ipa = [];
  List<bool> doneWord = [false, false, false, false];
  List<bool> doneIPA = [false, false, false, false];

  ButtonState wordState = ButtonState.normal;
  ButtonState ipaState = ButtonState.normal;
  @override
  void initState() {
    super.initState();
    word = options.map((e) => e.word).toList();
    word.shuffle();
    ipa = options.map((e) => e.ipa).toList();
    ipa.shuffle();
  }

  @override
  Widget build(BuildContext context) {
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
          value: 0.1,
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
                          child: ChoiceBtn(
                            value: word[index],
                            state: doneWord[index]
                                ? ButtonState.done
                                : selectedWordIDX == index
                                ? wordState
                                : ButtonState.normal,
                            onPressed: () {
                              if (selectedIPAIDX != null) {
                                setState(() {
                                  if (selectedWordIDX != index) {
                                    selectedWordIDX= index;
                                    wordState = ButtonState.selected;
                                  } else {
                                    selectedWordIDX = null;
                                    wordState = ButtonState.normal;
                                  }
                                });
                                var find = options.where(
                                  (o) => o.word == word[selectedWordIDX!],
                                );
                                if (word[index] == find.first.word) {
                                  doneWord[selectedWordIDX!] = true;
                                  doneIPA[selectedIPAIDX!] = true;
                                  selectedWordIDX = null;
                                  selectedIPAIDX = null;
                                  if (doneWord
                                      .where((d) => d == false)
                                      .isEmpty) {
                                    setState(() {
                                      answered = true;
                                    });
                                  }
                                } else {
                                  selectedWordIDX = null;
                                  selectedIPAIDX = null;
                                }
                              } else {
                                setState(() {
                                  if (selectedWordIDX == index) {
                                    selectedWordIDX = null;
                                    wordState = ButtonState.normal;
                                  } else {
                                    selectedWordIDX = index;
                                    wordState = ButtonState.selected;
                                  }
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 50),
                  ],
                ),
              ),
              Container(
                height: 125,
                width: 750,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListView.builder(
                      itemCount: options.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Center(
                          child: ChoiceBtn(
                            value: ipa[index],
                            state: doneIPA[index]
                                ? ButtonState.done
                                : selectedIPAIDX == index
                                ? ipaState
                                : ButtonState.normal,
                            onPressed: () {
                              print(
                                "i been touch mf${selectedIPAIDX?.toString() ?? "-1"}",
                              );

                              if (selectedWordIDX != null) {
                                print("int not first time");
                                setState(() {
                                  if (selectedIPAIDX != index) {
                                    print("in to seleted");
                                    selectedIPAIDX = index;
                                    ipaState = ButtonState.selected;
                                  } else {
                                    print("back to normal");
                                    selectedIPAIDX = null;
                                    ipaState = ButtonState.normal;
                                  }
                                });
                                var find = options.where(
                                  (o) => o.word == word[selectedWordIDX!],
                                );
                                if (ipa[index] == find.first.ipa) {
                                  doneWord[selectedWordIDX!] = true;
                                  doneIPA[selectedIPAIDX!] = true;
                                  selectedWordIDX = null;
                                  selectedIPAIDX = null;
                                  if (doneWord
                                      .where((d) => d == false)
                                      .isEmpty) {
                                    setState(() {
                                      answered = true;
                                    });
                                  }
                                } else {
                                  selectedWordIDX = null;
                                  selectedIPAIDX = null;
                                }
                              } else {
                                print("at else");
                                setState(() {
                                  if (selectedIPAIDX == index) {
                                    print("turn to normal");

                                    ipaState = ButtonState.normal;
                                    selectedIPAIDX = null;
                                  } else {
                                    selectedIPAIDX = index;
                                    ipaState = ButtonState.selected;
                                  }
                                });
                                print(
                                  "end with${selectedIPAIDX?.toString() ?? "-1"}",
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 50),
                  ],
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: answered ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ReviewScreen(
              right: right,
              onPressed: () {










              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  ReviewScreen({super.key, required this.right, required this.onPressed});
  final bool right;
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
                        elevation: right ? 10 : 4,
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

enum ButtonState { normal, selected, done }

class ChoiceBtn extends StatelessWidget {
  String value;
  ButtonState state;
  VoidCallback? onPressed;
  ChoiceBtn({
    super.key,
    required this.state,
    required this.value,
    required this.onPressed,
  });

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
    }

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
            side: BorderSide(color: borderColor, width: 4),
            backgroundColor: backgroundColor,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: textColor,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }
}
