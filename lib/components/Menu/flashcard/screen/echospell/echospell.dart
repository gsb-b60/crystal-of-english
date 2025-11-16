import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/screen/echospell/echospellNoti.dart';
import 'package:mygame/components/Menu/flashcard/screen/echospell/echospellUI.dart';
import 'package:provider/provider.dart';

class Echospell extends StatefulWidget {
  final int deck_id;
  Echospell({super.key, required this.deck_id});

  @override
  State<Echospell> createState() => _EchospellState();
}

class _EchospellState extends State<Echospell> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EchospellNoti()..getFlashcardList(widget.deck_id),
      child: Consumer<EchospellNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return EchospellUI();
        },
      ),
    );
  }
}
