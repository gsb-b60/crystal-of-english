import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/vocab/placementtest/library/placementtest.dart';
import 'package:mygame/state/player_profile.dart';
import 'package:mygame/vocab/placementtest/screen/endscreen.dart';
import 'package:mygame/vocab/placementtest/screen/quizscreen.dart';
import 'package:mygame/vocab/placementtest/screen/startscreen.dart';

class QuizApp extends StatefulWidget {
  const QuizApp({super.key});

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  late List<QuizQuestion> _questions;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final raw = await rootBundle.loadString(
      'assets/quiz/placementtest/placementtest.json',
    );

    final jsonList = (json.decode(raw) as List).cast<Map<String, dynamic>>();

    setState(() {
      _questions = QuizQuestion.listFromJson(jsonList);
    });
  }

  void _startQuiz() {
    setState(() {
      _score = 0;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: _questions,
          onFinish: (int finalScore) {
            _onQuizEnd(finalScore);
          },
        ),
      ),
    );
  }

  void _onQuizEnd(int finalScore) {
    final percent = finalScore / _questions.length;
    int level;
    if (percent >= 0.85) {
      level = 5;
    } else if (percent >= 0.7) {
      level = 4;
    } else if (percent >= 0.5) {
      level = 3;
    } else if (percent >= 0.3) {
      level = 2;
    } else {
      level = 1;
    }

    try {
      PlayerProfile.instance.setProficiencyLevel(level);
    } catch (e) {}

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EndScreen(
          score: finalScore,
          total: _questions.length,
          onRestart: _restartQuiz,
        ),
      ),
    );
  }

  void _restartQuiz() {
    setState(() {
      _score = 0;
      _questions.shuffle();
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: _questions,
          onFinish: (int finalScore) {
            _onQuizEnd(finalScore);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Placement Quiz',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Placement Test',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                  ),
                ),
                Card(
                  color: Colors.teal[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.quiz, size: 25, color: Colors.white70),
                        const SizedBox(height: 16),
                        const Text(
                          'Test Your English Level',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Take this quick placement test to find out which study deck suits you best.\n'
                          '15 questions will evaluate your grammar, vocabulary, and comprehension skills.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Good luck! 🎯',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                // ElevatedButton(
                //   onPressed: _startQuiz,
                //   child: const Text(
                //     'Start Quizz',
                //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                //   ),
                // ),
                GestureDetector(
                  onTap: _startQuiz,
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.primaryTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: const Text(
                        'Start Quizz',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
