import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuizQuestion {
  final String id;
  final String topic;
  final String type;          // "text" | "sound" | "text_sound" | "image_sound"
  final String prompt;
  final List<String> options;
  final int correctIndex;

  // THÊM:
  final String? sound;        // ví dụ: assets/quiz/animals/sounds/lion.mp3
  final String? image;        // ví dụ: assets/quiz/animals/images/lion.png

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
  /// Tự thử nhiều đường dẫn để phù hợp cấu trúc asset khác nhau:
  /// - assets/quiz/<topic>.json
  /// - assets/quiz/<topic>/<topic>.json
  /// - assets/quiz/<topic>/animals.json hoặc animal.json (nếu bạn đặt tên vậy)
  Future<List<QuizQuestion>> loadTopic(String topic) async {
    final candidates = <String>[
      'assets/quiz/$topic/animals.json', // hay dùng
    ];

    String? raw;
    Object? lastErr;
    for (final path in candidates) {
      try {
        raw = await rootBundle.loadString(path);
        // Nếu mở được 1 path là dừng.
        break;
      } catch (e) {
        lastErr = e;
      }
    }

    if (raw == null) {
      // Cho lỗi rõ ràng để bạn thấy trên console
      throw Exception('Không tìm thấy JSON cho topic "$topic". '
          'Hãy kiểm tra lại đường dẫn trong assets/pubspec.yaml. Lần thử cuối: $lastErr');
    }

    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['questions'] as List).cast<Map<String, dynamic>>();
    return list.map((m) => QuizQuestion.fromMap(m, topic)).toList();
  }
}
