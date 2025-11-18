import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/screen/sound&sight/sound&sightNoti.dart';
import 'package:mygame/components/Menu/flashcard/screen/sound&sight/sound&sightUI.dart';
import 'package:provider/provider.dart';

class SoundNSight extends StatefulWidget {
  SoundNSight({super.key, required this.deck_id});
  final int deck_id;
  @override
  State<SoundNSight> createState() => _SoundNSightState();
}

class _SoundNSightState extends State<SoundNSight> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SoundNSightNoti()..getFlashcardList(widget.deck_id),
      child: Consumer<SoundNSightNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return SoundNSightUI();
        },
      ),
    );
  }
}
