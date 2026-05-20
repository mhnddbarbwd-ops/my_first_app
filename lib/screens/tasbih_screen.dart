import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  int _totalCount = 0;
  final List<String> _adhkar = [
    'سبحان الله', 'الحمد لله', 'الله أكبر', 'لا إله إلا الله',
    'أستغفر الله', 'سبحان الله وبحمده', 'لا حول ولا قوة إلا بالله'
  ];
  int _selectedDhikr = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المسبحة الإلكترونية',
          style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _adhkar.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(
                    _adhkar[i],
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedDhikr == i ? Colors.white : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  selected: _selectedDhikr == i,
                  selectedColor: colorScheme.primary,
                  backgroundColor: colorScheme.surface,
                  onSelected: (_) => setState(() {
                    _selectedDhikr = i;
                    _count = 0;
                  }),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() {
              _count++;
              _totalCount++;
            }),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary.withOpacity(0.1), width: 8),
                  ),
                ),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_count',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 68,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'اضغط للتسبيح',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'إجمالي التسبيحات الكلي: $_totalCount',
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlBtn(Icons.refresh_rounded, 'إعادة ضبط', () => setState(() {
                _count = 0;
              }), colorScheme),
              const SizedBox(width: 16),
              _buildControlBtn(Icons.undo_rounded, 'تراجع آلي', () => setState(() {
                if (_count > 0) _count--;
                if (_totalCount > 0) _totalCount--;
              }), colorScheme),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, String label, VoidCallback onTap, ColorScheme colorScheme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
