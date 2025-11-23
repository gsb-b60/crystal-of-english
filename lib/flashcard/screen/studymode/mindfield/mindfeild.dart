import 'package:flutter/material.dart';
import 'package:mygame/flashcard/screen/studymode/mindfield/mindfieldnoti.dart';
import 'package:mygame/flashcard/screen/studymode/mindfield/mindfieldui.dart';
import 'package:provider/provider.dart';

class MindFeild extends StatefulWidget {
  final int deckID;
  const MindFeild({super.key, required this.deckID});

  @override
  State<MindFeild> createState() => _MindFeildState();
}

class _MindFeildState extends State<MindFeild> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Mindfieldnoti()..getFlashcardList(widget.deckID),
      child: Consumer<Mindfieldnoti>(
        builder: (context, provider, _) {
          if (provider.IsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return MindFeildUI();
        },
      ),
    );
  }
}
