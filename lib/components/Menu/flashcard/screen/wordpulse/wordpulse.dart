import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/screen/wordpulse/wordpulseNoti.dart';
import 'package:mygame/components/Menu/flashcard/screen/wordpulse/wordpulseUI.dart';
import 'package:provider/provider.dart';

class WordPulse extends StatefulWidget {
  WordPulse({super.key, required this.deck_id});
  int deck_id;
  @override
  State<WordPulse> createState() => _WordPulseState();
}

class _WordPulseState extends State<WordPulse> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordPulseNoti()..getFlashcardList(widget.deck_id),
      child: Consumer<WordPulseNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return WordPulseUI();
        },
      ),
    );
  }
}
