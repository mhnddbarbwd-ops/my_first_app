import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  final List<Map<String, dynamic>> _leagues = const [
    {'name': 'الدوري البرونزي', 'minXP': 0, 'color': Color(0xFFCD7F32), 'icon': Icons.shield_rounded},
    {'name': 'الدوري الفضي', 'minXP': 1000, 'color': Color(0xFFA8A8A8), 'icon': Icons.shield_rounded},
    {'name': 'الدوري الذهبي', 'minXP': 3000, 'color': Color(0xFFFFD700), 'icon': Icons.star_rounded},
    {'name': 'دوري الألماس', 'minXP': 5000, 'color': Color(0xFF4FC3F7), 'icon': Icons.diamond_rounded},
  ];

  final List<Map<String, dynamic>> _topUsers = const [
    {'name': 'أحمد', 'xp': 5200, 'streak': 45},
    {'name': 'فاطمة', 'xp': 4800, 'streak': 38},
    {'name': 'عمر', 'xp': 3500, 'streak': 22},
    {'name': 'أنت', 'xp': 2450, 'streak': 7, 'isMe': true},
    {'name': 'خالد', 'xp': 2100, 'streak': 15},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة الصدارة', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // الدوريات
          Text('الدوريات', style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('يتم التحديث كل يوم أحد', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _leagues.length,
              itemBuilder: (context, i) {
                final league = _leagues[i];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: (league['color'] as Color).withOpacity(0.1),
                    border: Border.all(color: (league['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(league['icon'], color: league['color'], size: 30),
                      const SizedBox(height: 8),
                      Text(league['name'], style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('+${league['minXP']}XP', style: TextStyle(fontSize: 12, color: league['color'])),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // قائمة المتصدرين
          Text('المتصدرون هذا الأسبوع', style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ..._topUsers.asMap().entries.map((e) {
            final user = e.value;
            final rank = e.key + 1;
            final isMe = user['isMe'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isMe ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
                border: isMe ? Border.all(color: colorScheme.primary) : null,
              ),
              child: Row(
                children: [
                  Text('$rank', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w900, color: rank <= 3 ? Colors.amber : Colors.grey)),
                  const SizedBox(width: 12),
                  CircleAvatar(backgroundColor: colorScheme.primary.withOpacity(0.1), child: Text(user['name'][0])),
                  const SizedBox(width: 10),
                  Expanded(child: Text(user['name'], style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600))),
                  Text('${user['xp']} XP', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.primary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}