import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuizQuestion {
  final String id;
  final String topic;        // ví dụ: "animals"
  final String type;         // "fill" (điền từ) — để sau mở rộng trắc nghiệm, matching, v.v.
  final String prompt;       // câu hỏi hiển thị (ví dụ: "The ___ jumps over the fence.")
  final List<String> options;  // 4 đáp án A/B/C/D
  final int correctIndex;      // 0..3

  const QuizQuestion({
    required this.id,
    required this.topic,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> m, String topic) {
    return QuizQuestion(
      id: m['id'] as String,
      topic: topic,
      type: m['type'] as String,
      prompt: m['prompt'] as String,
      options: (m['options'] as List).map((e) => e as String).toList(),
      correctIndex: m['correctIndex'] as int,
    );
  }
}

class QuizRepository {
  // assets/quiz/<topic>.json
  Future<List<QuizQuestion>> loadTopic(String topic) async {
    final raw = await rootBundle.loadString('assets/quiz/$topic.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['questions'] as List).cast<Map<String, dynamic>>();
    return list.map((m) => QuizQuestion.fromMap(m, topic)).toList();
  }
}
