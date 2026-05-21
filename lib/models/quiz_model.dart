class QuizModel {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;

  QuizModel({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.category = 'عام',
  });
}