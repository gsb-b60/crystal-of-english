import 'package:flutter/material.dart';
import 'newwayreview.dart';

class FrontSide extends StatelessWidget {
  const FrontSide({super.key, required this.widget});

  final FlashCardItem widget;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.yellow[70],
      child: Center(
        child: Text(
          widget.card?.word ?? '',
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 167, 14, 77),
          ),
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}