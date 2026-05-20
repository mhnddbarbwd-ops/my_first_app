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
    'سبحان الله وبحمده، سبحان الله العظيم',
    'الحمد لله حمداً كثيراً طيباً مباركاً فيه',
    'الله أكبر كبيراً، والحمد لله كثيراً',
    'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد',
    'أستغفر الله العظيم وأتوب إليه',
    'لا حول ولا قوة إلا بالله العلي العظيم',
    'اللهم صلِّ وسلم وبارك على نبينا محمد'
  ];
  int _selectedDhikr = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('المسبحة الإلكترونية', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // جزء اختيار الذكر الأفقي
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _adhkar.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(
                    _adhkar[i].split('،')[0], // إظهار الشق الأول من الذكر في شريط الاختيار للحفاظ على المساحة
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 13,
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
          
          const SizedBox(height: 30),
          
          // حل مشكلة الاقتطاع: صندوق نصي ذكي ومرن يعرض الذكر كاملاً وبخط واضح
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.primary.withOpacity(0.12)),
              ),
              child: Text(
                _adhkar[_selectedDhikr],
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const Spacer(),
          
          // زر عداد التسبيح الدائري
          GestureDetector(
            onTap: () => setState(() {
              _count++;
              _totalCount++;
            }),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary.withOpacity(0.08), width: 12),
                  ),
                ),
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: colorScheme.primary.withOpacity(0.35), blurRadius: 40, offset: const Offset(0, 15)),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_count',
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text('اضغط هنا', style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(24)),
            child: Text(
              'مجموع تسبيحاتك الكلي: $_totalCount',
              style: GoogleFonts.ibmPlexSansArabic(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlBtn(Icons.refresh_rounded, 'تصفير', () => setState(() => _count = 0), colorScheme),
              const SizedBox(width: 16),
              _buildControlBtn(Icons.undo_rounded, 'تراجع خطوة', () => setState(() {
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
            Text(label, style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
