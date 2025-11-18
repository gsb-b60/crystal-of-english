import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/flashcard/screen/sound&sight/sound&sightUI.dart';

class SoundNSight extends StatefulWidget {
  const SoundNSight({super.key});

  @override
  State<SoundNSight> createState() => _SoundNSightState();
}

class _SoundNSightState extends State<SoundNSight> {
  @override
  Widget build(BuildContext context) {
    return SoundNSightUI();
  }
}