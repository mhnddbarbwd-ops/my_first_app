import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/screens/challenges_screen.dart';
import 'package:nafahat/screens/quiz_screen.dart';
import 'package:nafahat/screens/leaderboard_screen.dart';
import 'package:nafahat/screens/achievements_screen.dart';

class HimamHubScreen extends StatelessWidget {
  const HimamHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('هِمَمْ', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, fontSize: 26, color: colorScheme.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 0.95,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          children: [
            _buildHubCard(
              icon: Icons.flag_rounded,
              title: 'التحديات',
              subtitle: 'يومية وموقوتة',
              color: const Color(0xFF2E7D32),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen())),
            ),
            _buildHubCard(
              icon: Icons.quiz_rounded,
              title: 'الاختبارات',
              subtitle: 'مسارات تعليمية',
              color: const Color(0xFF1565C0),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen())),
            ),
            _buildHubCard(
              icon: Icons.leaderboard_rounded,
              title: 'لوحة الصدارة',
              subtitle: 'دوريات وتنافس',
              color: const Color(0xFFE65100),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
            ),
            _buildHubCard(
              icon: Icons.emoji_events_rounded,
              title: 'الأوسمة',
              subtitle: 'خزنة الإنجازات',
              color: const Color(0xFF6A1B9A),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [color.withOpacity(0.9), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: Colors.white, size: 28)),
                const Spacer(),
                Text(title, style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}