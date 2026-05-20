import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/services/quran_challenge_service.dart';
import 'package:nafahat/models/quran_challenge.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final QuranChallengeService _service = QuranChallengeService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final challenges = _service.challenges;

    return Scaffold(
      appBar: AppBar(
        title: Text('التحديات الإيمانية', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: challenges.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_rounded, size: 64, color: colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('لا توجد تحديات نشطة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 8),
                  Text('يمكنك بدء تحدي جديد من صفحة القرآن', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return _buildChallengeCard(challenge, colorScheme);
              },
            ),
    );
  }

  Widget _buildChallengeCard(QuranChallenge challenge, ColorScheme colorScheme) {
    final progress = challenge.progress;
    final remainingDays = challenge.remainingDays > 0 ? challenge.remainingDays : 1;
    final pagesPerDay = (challenge.remainingPages / remainingDays).ceil();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.menu_book_rounded, color: colorScheme.primary, size: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(challenge.title, style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w900)),
                  Text('الصفحات ${challenge.startPage} - ${challenge.endPage}', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))),
                ]),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                onPressed: () {
                  _service.deleteChallenge(challenge.id);
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${challenge.completedPages} / ${challenge.totalPages} صفحة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.primary)),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.secondary)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.04), borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('$remainingDays', 'يوم متبقي'),
                _buildStat('$pagesPerDay', 'صفحة/يوم'),
                _buildStat('${challenge.streakDays}', 'Streak'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdateDialog(challenge),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('تحديث التقدم'),
                  style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
        Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
      ],
    );
  }

  void _showUpdateDialog(QuranChallenge challenge) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تحديث التقدم', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'عدد الصفحات المكتملة',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final pages = int.tryParse(controller.text) ?? 0;
              if (pages > 0 && pages <= challenge.totalPages) {
                _service.updateProgress(challenge.id, pages);
                setState(() {});
                Navigator.pop(ctx);
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}