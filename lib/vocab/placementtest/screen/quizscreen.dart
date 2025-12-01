import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/vocab/placementtest/library/placementtest.dart';

import 'package:mygame/vocab/placementtest/library/widget.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final void Function(int finalScore) onFinish;
  const QuizScreen({
    super.key,
    required this.questions,
    required this.onFinish,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int score = 0;
  bool showQuote = false;
  final List<String> quotes = [
    "🔥 Fight for your grade! 🔥",
    "💪 Keep pushing, you can do it!",
    "🎯 Stay focused, aim high!",
    "🚀 Every answer counts!",
    "🏆 Victory is near!",
    "⚡ Don't give up now!",
    "🌟 Believe in yourself!",
  ];
  String currentQuote = "";

  late PageController _pageController;
  void _selectAnswer(int index) {
    final q = widget.questions[currentIndex];
    if (index == q.correctIndex) {
      score++;
      print(score);
    }
    if (currentIndex < widget.questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      widget.onFinish(score);
    }
    setState(() {
      currentQuote = quotes[Random().nextInt(quotes.length)];
      showQuote = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => showQuote = false);

      if (currentIndex < widget.questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        widget.onFinish(score);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / widget.questions.length,
                minHeight: 30,
                color: AppColor.accentTeal,
                backgroundColor: Colors.grey[850],
              ),
            ),
            Text(
              'Question ${currentIndex + 1}/${widget.questions.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),

        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.teal,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.questions.length,
            itemBuilder: (context, index) {
              final q = widget.questions[index];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: QuestionCard(
                  question: q.question,
                  choices: q.choices,
                  onSelected: _selectAnswer,
                ),
              );
            },
          ),

          // if (showQuote)
          //   Center(
          //     child: AnimatedOpacity(
          //       opacity: showQuote ? 1.0 : 0.0,
          //       duration: const Duration(milliseconds: 800),
          //       child: Container(
          //         height: 420,
          //         width: 800,
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 24,
          //           vertical: 16,
          //         ),
          //         decoration: BoxDecoration(
          //           color: const Color.fromARGB(255, 249, 180, 252),
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: Center(
          //           child: Text(
          //             currentQuote,
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               fontSize: 34,
          //               fontWeight: FontWeight.bold,
          //               color: Color.fromARGB(255, 255, 255, 255),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
