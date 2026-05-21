import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:provider/provider.dart';
import 'package:nafahat/models/quiz_model.dart';
import 'package:nafahat/providers/user_progress_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController _pageController = PageController();
  final CountDownController _timerController = CountDownController();
  int _currentIndex = 0;
  int _correctAnswers = 0;
  bool _quizCompleted = false;

  final List<QuizModel> _questions = [
    QuizModel(question: 'ما هي أول سورة نزلت في القرآن الكريم؟', options: ['الفاتحة', 'العلق', 'البقرة', 'الإخلاص'], correctAnswerIndex: 1, category: 'قرآن'),
    QuizModel(question: 'كم عدد آيات القرآن الكريم؟', options: ['6236', '6666', '6000', '7000'], correctAnswerIndex: 0, category: 'قرآن'),
    QuizModel(question: 'من هو أول الأنبياء؟', options: ['نوح', 'إبراهيم', 'آدم', 'موسى'], correctAnswerIndex: 2, category: 'أنبياء'),
    QuizModel(question: 'ما هي السورة التي تسمى قلب القرآن؟', options: ['البقرة', 'يس', 'الرحمن', 'الفاتحة'], correctAnswerIndex: 1, category: 'قرآن'),
    QuizModel(question: 'كم عدد أركان الإسلام؟', options: ['4', '6', '5', '7'], correctAnswerIndex: 2, category: 'فقه'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _answerQuestion(int selectedIndex) {
    if (_quizCompleted) return;
    final question = _questions[_currentIndex];
    if (selectedIndex == question.correctAnswerIndex) {
      _correctAnswers++;
      Provider.of<UserProgressProvider>(context, listen: false).addXP(20);
    }
    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      _timerController.restart();
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _onTimerComplete() {
    _answerQuestion(-1);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_quizCompleted) {
      return _buildResultScreen(colorScheme);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_currentIndex + 1}/${_questions.length}', style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w600)),
                CircularCountDownTimer(
                  duration: 15,
                  initialDuration: 0,
                  controller: _timerController,
                  width: 40,
                  height: 40,
                  ringColor: Colors.grey[300]!,
                  fillColor: colorScheme.primary,
                  backgroundColor: Colors.transparent,
                  strokeWidth: 4.0,
                  strokeCap: StrokeCap.round,
                  textFormat: CountdownTextFormat.S,
                  isReverse: true,
                  isReverseAnimation: true,
                  onComplete: _onTimerComplete,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _timerController.restart();
              },
              itemBuilder: (context, index) {
                final question = _questions[index];
                return _buildQuestionPage(question, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(QuizModel question, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(question.question, style: GoogleFonts.ibmPlexSansArabic(fontSize: 22, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(question.category, style: TextStyle(color: colorScheme.secondary, fontSize: 14)),
          const SizedBox(height: 24),
          ...question.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => _answerQuestion(idx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.primary.withOpacity(0.2))),
                ),
                child: Text(option, style: GoogleFonts.ibmPlexSansArabic(fontSize: 18)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultScreen(ColorScheme colorScheme) {
    final percentage = (_correctAnswers / _questions.length * 100).toInt();
    return Scaffold(
      appBar: AppBar(title: Text('النتيجة', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(percentage >= 80 ? Icons.emoji_events : Icons.school, size: 80, color: percentage >= 80 ? Colors.amber : colorScheme.primary),
            const SizedBox(height: 20),
            Text('$percentage%', style: GoogleFonts.ibmPlexSansArabic(fontSize: 48, fontWeight: FontWeight.w900, color: colorScheme.primary)),
            Text('$_correctAnswers / ${_questions.length} إجابات صحيحة', style: TextStyle(fontSize: 18, color: colorScheme.onSurface.withOpacity(0.7))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('عودة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}