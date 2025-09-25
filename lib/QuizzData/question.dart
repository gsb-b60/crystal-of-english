class Question {
  final String id;
  final String type;
  final String prompt;
  final List<String> options;
  final int correct;
  final String? image;
  final String? sound;

  Question({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correct,
    this.image,
    this.sound,
  });
}