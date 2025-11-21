import 'package:flutter/material.dart';
import 'package:mygame/flashcard/screen/neuropick/neuropickNoti.dart';
import 'package:mygame/flashcard/screen/neuropick/neuropickUI.dart';
import 'package:provider/provider.dart';

class NeuroPick extends StatefulWidget {
  NeuroPick({super.key, required this.deckID});
  final int deckID ;
  @override
  State<NeuroPick> createState() => _NeuroPickState();
}

class _NeuroPickState extends State<NeuroPick> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NeuroPickNoti()..getFlashcardList(widget.deckID),
      child: Consumer<NeuroPickNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return NeuroPickUI();
        },
      )
    );
  }
}