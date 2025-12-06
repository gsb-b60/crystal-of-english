import 'package:flutter/material.dart';

class EndScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const EndScreen({
    super.key,
    required this.score,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (score / total);
    int percentInt = (percent * 100).toInt();

    String band;
    String tip;
    Color gradeColor;
    if (percent >= 0.85) {
      band = "Band 8-9 / C1+";
      tip = "Recommend Deck: \n 4000 Essential English Words";
      gradeColor = Colors.greenAccent;
    } else if (percent >= 0.7) {
      band = "Band 7 / B2+";
      tip =
          "Recommend Deck: \n Cambridge_Vocabulary_for_IELTS_-_Advanced\n 4000 Essential English Words";
      gradeColor = Colors.tealAccent;
    } else if (percent >= 0.5) {
      band = "Band 5-6 / B1";
      tip =
          "Recommend Deck: \n Cambridge_Vocabulary_for_IELTS_-_Advanced\n 4000 Essential English Words";
      gradeColor = Colors.orangeAccent;
    } else {
      band = "Band 3-4 / A2-B1";
      tip = "Recommend Deck: \n Cambridge_Vocabulary_for_IELTS_-_Advanced";
      gradeColor = Colors.redAccent;
    }

    final Map<String, String> skillAnalysis = {
      "Grammar Accuracy": percent >= 0.6 ? "Strong" : "OK",
      "Tense Control": percent >= 0.5 ? "Average" : "Ok",
      "Sentence Structures": percent >= 0.7 ? "Excellent" : "Good",
      "Error Patterns": percent >= 0.85 ? "Excellent" : "Good",
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz Finished',
                    style: TextStyle(
                      color: gradeColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Score: $score / $total (${percentInt}%)',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Estimated IELTS Band: $band',
                    style: TextStyle(
                      color: gradeColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tip,
                    style: const TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 40),

            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: gradeColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 30,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: skillAnalysis.entries.map((entry) {
                      Color skillColor;
                      if (entry.value.contains("Excellent") ||
                          entry.value.contains("Strong") ||
                          entry.value.contains("Good")) {
                        skillColor = Colors.greenAccent;
                      } else if (entry.value.contains("Average")) {
                        skillColor = Colors.tealAccent;
                      } else {
                        skillColor = Colors.redAccent;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 200,
                              child: Text(
                                "${entry.key}:",
                                style: TextStyle(
                                  color: skillColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Text(
                              "${entry.value}",
                              style: TextStyle(color: skillColor, fontSize: 20),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: gradeColor,
                          ),
                          child: Text(
                            'Back to Levels',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
