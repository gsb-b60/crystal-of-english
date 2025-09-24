import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuizQuestion {
  final String id;
  final String topic;
  final String type;          // "text"  "sound"  "text_sound"  "image_sound"
  final String prompt;
  final List<String> options;
  final int correctIndex;

  final String? sound;       
  final String? image;        

  const QuizQuestion({
    required this.id,
    required this.topic,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.sound,
    this.image,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> m, String topic) {
    return QuizQuestion(
      id: m['id'] as String,
      topic: topic,
      type: m['type'] as String,
      prompt: m['prompt'] as String,
      options: (m['options'] as List).map((e) => e as String).toList(),
      correctIndex: m['correctIndex'] as int,
      sound: m['sound'] as String?,   // <- lấy từ JSON
      image: m['image'] as String?,   // <- lấy từ JSON
    );
  }
}

class QuizRepository {
  Future<List<QuizQuestion>> loadTopic(String topic) async {
    final candidates = <String>[
      'assets/quiz/$topic/animals.json', //temp
    ];

    String? raw;
    Object? lastErr;
    for (final path in candidates) {
      try {
        raw = await rootBundle.loadString(path);
        break;
      } catch (e) {
        lastErr = e;
      }
    }

    if (raw == null) {
      throw Exception('cant not find "$topic"');
    }

    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['questions'] as List).cast<Map<String, dynamic>>();
    return list.map((m) => QuizQuestion.fromMap(m, topic)).toList();
  }
}
