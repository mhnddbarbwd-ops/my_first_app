import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:nafahat/providers/user_progress_provider.dart';
import 'package:nafahat/models/challenge_model.dart';
import 'package:nafahat/models/user_progress.dart';
import 'package:nafahat/screens/quiz_screen.dart';

class HimamScreen extends StatelessWidget {
  const HimamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('هِمَمْ', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, fontSize: 26, color: colorScheme.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<UserProgressProvider>(
        builder: (context, provider, child) {
          final progress = provider.progress;
          final challenges = provider.challenges;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildProgressCard(context, progress, colorScheme),
              const SizedBox(height: 24),
              Text('التحديات', style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.primary)),
              const SizedBox(height: 12),
              ...challenges.map((challenge) => _buildChallengeCard(challenge, context, colorScheme)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen())),
                icon: const Icon(Icons.quiz),
                label: Text('اختبار', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, UserProgress? progress, ColorScheme colorScheme) {
    final pagesRead = progress?.totalPagesRead ?? 0;
    final streak = progress?.currentStreak ?? 0;
    final bestStreak = progress?.bestStreak ?? 0;
    final xp = progress?.totalXP ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [colorScheme.primary.withOpacity(0.15), colorScheme.secondary.withOpacity(0.08)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                animation: true,
                percent: (pagesRead / 100).clamp(0.0, 1.0),
                center: Text('$pagesRead', style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.primary)),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: colorScheme.primary,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
              ),
              Column(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                  Text('$streak', style: GoogleFonts.ibmPlexSansArabic(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.orange)),
                  Text('Streak', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                  Text('$xp', style: GoogleFonts.ibmPlexSansArabic(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.amber)),
                  Text('XP', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('أفضل Streak: $bestStreak', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge, BuildContext context, ColorScheme colorScheme) {
    final isCompleted = challenge.isCompleted;
    final progress = challenge.progress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isCompleted ? Colors.green.withOpacity(0.1) : colorScheme.surface,
        border: Border.all(color: isCompleted ? Colors.green : colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForChallenge(challenge.icon),
            color: isCompleted ? Colors.green : colorScheme.primary,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title, style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w700, color: isCompleted ? Colors.green : colorScheme.onSurface)),
                Text(challenge.description, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted) const Icon(Icons.check_circle, color: Colors.green, size: 28),
        ],
      ),
    );
  }

  IconData _getIconForChallenge(String icon) {
    switch (icon) {
      case 'auto_stories':
        return Icons.auto_stories;
      case 'menu_book':
        return Icons.menu_book;
      case 'library_books':
        return Icons.library_books;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      default:
        return Icons.star;
    }
  }
}
