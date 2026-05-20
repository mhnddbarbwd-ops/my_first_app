import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  final List<Map<String, dynamic>> _dailyChallenges = const [
    {'title': 'قراءة أذكار الصباح', 'points': 50, 'icon': Icons.wb_sunny_rounded},
    {'title': 'قراءة سورة الملك', 'points': 80, 'icon': Icons.nightlight_rounded},
    {'title': 'ورد القراءة اليومي', 'points': 100, 'icon': Icons.menu_book_rounded},
  ];

  final List<Map<String, dynamic>> _timedChallenges = const [
    {'title': 'تحدي سورة البقرة', 'subtitle': 'قراءتها كاملة خلال 3 أيام', 'points': 500, 'days': 3},
    {'title': 'تحدي جزء تبارك', 'subtitle': 'قراءته كاملاً في أسبوع', 'points': 300, 'days': 7},
    {'title': 'تحدي ختم القرآن', 'subtitle': 'ختم المصحف كاملاً', 'points': 2000, 'days': 30},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('التحديات الإيمانية', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('التحديات اليومية', style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.primary)),
          const SizedBox(height: 4),
          Text('تتجدد كل 24 ساعة', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 16),
          ..._dailyChallenges.map((c) => _buildChallengeCard(c, colorScheme, true)),
          const SizedBox(height: 28),
          Text('التحديات الموقوتة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.secondary)),
          const SizedBox(height: 4),
          Text('تحديات طويلة المدى', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 16),
          ..._timedChallenges.map((c) => _buildChallengeCard(c, colorScheme, false)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge, ColorScheme colorScheme, bool isDaily) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDaily ? colorScheme.primary.withOpacity(0.1) : colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(challenge['icon'], color: isDaily ? colorScheme.primary : colorScheme.secondary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(challenge['title'], style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w700)),
              if (challenge['subtitle'] != null) Text(challenge['subtitle'], style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))),
            ]),
          ),
          Column(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              Text('+${challenge['points']}', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.amber)),
            ],
          ),
        ],
      ),
    );
  }
}