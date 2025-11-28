import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/DailyLesson/libWidget/reviewScreen.dart';
import 'package:mygame/flashcard/screen/studymode/speechword/speechwordNoti.dart';
import 'package:provider/provider.dart';

class Speechword extends StatefulWidget {
  Speechword({super.key, required this.deck_id});
  int deck_id;
  @override
  State<Speechword> createState() => _SpeechwordState();
}

class _SpeechwordState extends State<Speechword> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpeechWordNoti()..getFlashcardList(widget.deck_id),
      child: Consumer<SpeechWordNoti>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return CircularProgressIndicator();
          }
          return SpeechWordUI();
        },
      ),
    );
  }
}

class SpeechWordUI extends StatefulWidget {
  const SpeechWordUI({super.key});

  @override
  State<SpeechWordUI> createState() => _SpeechWordUIState();
}

class _SpeechWordUIState extends State<SpeechWordUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpeechWordNoti>();
    final reader= context.read<SpeechWordNoti>();
    provider.initSTT();
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 40),
                  Text(
                    "Speak this word",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.word,
                    style: TextStyle(color: AppColor.lightText, fontSize: 45),
                  ),
                  SizedBox(width: 30),
                  Text(
                    provider.ipa,
                    style: TextStyle(color: AppColor.lightText, fontSize: 30,fontFamily: 'roboto'),
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  reader.startListening();
                },
                child: Container(
                  height: 100,
                  width: 400,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: BoxBorder.all(color: AppColor.darkBorder, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, color: AppColor.bluePrimary, size: 40),
                      Text(
                        "TAP TO SPEECH",
                        style: TextStyle(
                          color: AppColor.bluePrimary,
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
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
            child: ReviewScreen(right: provider.right, answer: provider.word, onPressed: () {
              reader.SetNext();
            }),
          ),
        ],
      ),
    );
  }
}
