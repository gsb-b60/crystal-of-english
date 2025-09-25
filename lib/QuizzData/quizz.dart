import "question.dart";

class Quizz {
  final int id;
  final String topic;
  final List<Question> questions;

  Quizz({
    required this.id,
    required this.topic,
    required this.questions,
  });
}

