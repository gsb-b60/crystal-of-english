import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/screen/phonemix/phonemixUI.dart';

class PhoneMix extends StatefulWidget {
  int deckID;
  PhoneMix({super.key,required this.deckID});

  @override
  State<PhoneMix> createState() => _PhoneMixState();
}

class _PhoneMixState extends State<PhoneMix> {
  @override
  Widget build(BuildContext context) {
    return PhoneMixUI();
  }
}