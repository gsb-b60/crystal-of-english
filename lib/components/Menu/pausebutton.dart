import 'package:flutter/material.dart';
import 'package:mygame/main.dart';

class PauseButton extends StatelessWidget {
  final MyGame game;
  const PauseButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            game.pauseEngine();
            game.overlays.add('PauseMenu'); // show menu pause
            game.overlays.remove('PauseButton'); // hide this button while menu is open
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pause, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
