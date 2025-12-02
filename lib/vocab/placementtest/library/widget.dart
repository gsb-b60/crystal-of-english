import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final List<String> choices;
  final Function(int) onSelected;

  const QuestionCard({
    super.key,
    required this.question,
    required this.choices,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
            const SizedBox(height: 16),
            ...List.generate(choices.length, (index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => onSelected(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColor.primaryTeal,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(
                        choices[index],
                        style: const TextStyle(color: Colors.white, fontSize: 23),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 4),
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.teal,
                  //     ),
                  //     onPressed: () => onSelected(index),
                  //     child: Text(
                  //       choices[index],
                  //       style: const TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 23,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
