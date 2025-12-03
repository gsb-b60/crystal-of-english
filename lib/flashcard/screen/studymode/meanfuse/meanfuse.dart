import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/screen/studymode/echospell/echospellUI.dart';
import 'package:mygame/flashcard/screen/studymode/meanfuse/meanfuseNoti.dart';
import 'package:provider/provider.dart';

class Meanfuse extends StatefulWidget {
  int deck_id;
  Meanfuse({super.key, required this.deck_id});

  @override
  State<Meanfuse> createState() => _MeanfuseState();
}

class _MeanfuseState extends State<Meanfuse> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Meanfusenoti()..getFlashcardList(widget.deck_id),
      child: Consumer<Meanfusenoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return MeanfuseUI();
        },
        child: MeanfuseUI(),
      ),
    );
  }
}

class MeanfuseUI extends StatelessWidget {
  const MeanfuseUI({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Meanfusenoti>();
    final reader = context.read<Meanfusenoti>();
    final list = provider.SetUpList();
    final listWord = provider.SetUpListWord();
    final ipa = provider.SetIPA();
    final listState = provider.GetListState();
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
                    "Tap to build the word.",
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
                width: 750,
                child: Center(
                  child: Text(
                    provider.mean,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
              Container(
                height: 70,
                child: SingleChildScrollView(
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: provider.answered ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ReviewScreen(
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
