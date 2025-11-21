import 'package:flutter/material.dart';
import 'package:mygame/flashcard/screen/echofuse/echofuseNoti.dart';
import 'package:mygame/flashcard/screen/echofuse/echofuseUI.dart';
import 'package:provider/provider.dart';

class EchoFuse extends StatefulWidget {
  EchoFuse({super.key, required this.deck_id});
  int deck_id;
  @override
  State<EchoFuse> createState() => _EchoFuseState();
}

class _EchoFuseState extends State<EchoFuse> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EchoFuseNoti()..getFlashcardList(widget.deck_id),
      child: Consumer<EchoFuseNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return EchoFuseUI();
        },
      ),
    );
  }
}
