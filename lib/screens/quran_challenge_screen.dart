import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/models/quran_challenge.dart';
import 'package:nafahat/services/quran_challenge_service.dart';
import 'package:uuid/uuid.dart';

class QuranChallengeScreen extends StatefulWidget {
  final int initialPage;
  const QuranChallengeScreen({super.key, this.initialPage = 1});

  @override
  State<QuranChallengeScreen> createState() => _QuranChallengeScreenState();
}

class _QuranChallengeScreenState extends State<QuranChallengeScreen> {
  final _titleController = TextEditingController();
  int _startPage = 1;
  int _endPage = 10;
  int _durationDays = 7;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _startPage = widget.initialPage;
    _endPage = widget.initialPage + 9;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalPages = _endPage - _startPage + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('تحدي جديد', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'اسم التحدي', hintText: 'مثلاً: ختم سورة البقرة',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              prefixIcon: Icon(Icons.edit, color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _buildPageSelector('صفحة البداية', _startPage, (v) => setState(() => _startPage = v.clamp(1, 604)))),
            const SizedBox(width: 12),
            Expanded(child: _buildPageSelector('صفحة النهاية', _endPage, (v) => setState(() => _endPage = v.clamp(1, 604)))),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildSummary('إجمالي الصفحات', '$totalPages'),
              _buildSummary('المدة (أيام)', '$_durationDays'),
              _buildSummary('صفحات/يوم', '${(totalPages / _durationDays).ceil()}'),
            ]),
          ),
          const SizedBox(height: 20),
          Text('المدة (أيام)', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w600)),
          Slider(value: _durationDays.toDouble(), min: 1, max: 90, divisions: 89, label: '$_durationDays يوم', onChanged: (v) => setState(() => _durationDays = v.toInt())),
          const SizedBox(height: 20),
          SwitchListTile(title: Text('تفعيل التذكير اليومي', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14)), value: _reminderEnabled, onChanged: (v) => setState(() => _reminderEnabled = v)),
          if (_reminderEnabled)
            ListTile(
              title: Text('وقت التذكير', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14)),
              trailing: Text(_reminderTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _reminderTime);
                if (time != null) setState(() => _reminderTime = time);
              },
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty) return;
              final challenge = QuranChallenge(
                id: const Uuid().v4(),
                title: _titleController.text.trim(),
                startPage: _startPage,
                endPage: _endPage,
                totalPages: totalPages,
                startDate: DateTime.now(),
                endDate: DateTime.now().add(Duration(days: _durationDays)),
                reminderEnabled: _reminderEnabled,
                reminderTime: '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
              );
              QuranChallengeService().addChallenge(challenge);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم بدء تحدي "${challenge.title}" بنجاح!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            child: Text('بدء التحدي', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  Widget _buildPageSelector(String label, int value, Function(int) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
      const SizedBox(height: 4),
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2))),
        child: Row(children: [
          IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => onChanged(value - 1)),
          Expanded(child: Text('$value', textAlign: TextAlign.center, style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w900))),
          IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => onChanged(value + 1)),
        ]),
      ),
    ]);
  }

  Widget _buildSummary(String label, String value) {
    return Column(children: [
      Text(value, style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
      Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
    ]);
  }
}
