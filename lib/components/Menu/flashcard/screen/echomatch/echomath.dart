import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/screen/echomatch/echomatchNoti.dart';
import 'package:mygame/components/Menu/flashcard/screen/echomatch/echomathUI.dart';
import 'package:provider/provider.dart';

class EchoMatch extends StatefulWidget {
  EchoMatch({super.key, required this.deck_id});
  int deck_id;
  @override
  State<EchoMatch> createState() => _EchoMatchState();
}

class _EchoMatchState extends State<EchoMatch> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EchoMatchNoti()..getFlashcardList(widget.deck_id),
      child: Consumer<EchoMatchNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return EchoMatchUI();
        },
      ),
    );
  }
}
