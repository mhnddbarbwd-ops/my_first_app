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
          'المسبحة',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _adhkar.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: FilterChip(
                  label: Text(
                    _adhkar[i],
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 13,
                      color: _selectedDhikr == i
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  selected: _selectedDhikr == i,
                  onSelected: (_) => setState(() {
                    _selectedDhikr = i;
                    _count = 0;
                  }),
                  selectedColor: colorScheme.primary.withOpacity(0.15),
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => setState(() {
              _count++;
              _totalCount++;
            }),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.25),
                        colorScheme.secondary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_count',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'المجموع: $_totalCount',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlBtn(Icons.refresh, 'تصفير', () => setState(() {
                _count = 0;
                _totalCount = 0;
              }), colorScheme),
              const SizedBox(width: 20),
              _buildControlBtn(Icons.undo, 'تراجع', () => setState(() {
                if (_count > 0) _count--;
                if (_totalCount > 0) _totalCount--;
              }), colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, String label, VoidCallback onTap, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.15),
              colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}