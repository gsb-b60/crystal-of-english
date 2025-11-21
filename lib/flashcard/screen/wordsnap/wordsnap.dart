import 'package:flutter/material.dart';
import 'package:mygame/flashcard/screen/mindfield/mindfieldnoti.dart';
import 'package:mygame/flashcard/screen/wordsnap/wordsnapNoti.dart';
import 'package:mygame/flashcard/screen/wordsnap/wordsnapUI.dart';
import 'package:provider/provider.dart';

class WordSnap extends StatefulWidget {
  WordSnap({super.key, required this.deck_id});
  int deck_id;
  @override
  State<WordSnap> createState() => _WordSnapState();
}

class _WordSnapState extends State<WordSnap> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordSnapNoti()..getFlashcardList(widget.deck_id),
      child: Consumer<WordSnapNoti>(
        builder: (context, provider, _) {
          if (provider.IsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return WordSnapUI();
        },
      ),
    );
  }
}
