import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/screens/quran_screen.dart';
import 'package:nafahat/screens/tasbih_screen.dart';
import 'package:nafahat/screens/hadith_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTime = '';
  String _hijriDate = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    HijriDate.setLocal('ar');
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final makkahTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    final timeFormat = DateFormat('hh:mm:ss a', 'ar');
    final today = HijriDate.now();
    const months = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    setState(() {
      _currentTime = timeFormat.format(makkahTime);
      _hijriDate = '${today.hDay} ${months[today.hMonth - 1]} ${today.hYear} هـ';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.wb_sunny_outlined),
          onPressed: () {}, // للتطوير المستقبلي للثيم يدوياً
        ),
        title: Text(
          'نَـفَـحَـات',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: 1.2,
            color: colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateTimeCard(colorScheme, isDark),
              const SizedBox(height: 32),
              Text(
                'الخدمات والمميزات',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMainButton(
                    icon: Icons.menu_book_rounded,
                    label: 'القرآن الكريم',
                    subtitle: 'تصفح وتدبر وبحث',
                    gradientColors: [const Color(0xFF0B3C18), const Color(0xFF1B5E20)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen())),
                  ),
                  _buildMainButton(
                    icon: Icons.mosque_rounded,
                    label: 'مواقيت ومؤشرات',
                    subtitle: 'الصلاة والقبلة',
                    gradientColors: [const Color(0xFFC5A880), const Color(0 tap: 0xFF9E7E50)],
                    onTap: () {}, // شاشة المواقيت حسب مشروعك الأصلي
                  ),
                  _buildMainButton(
                    icon: Icons.book_rounded,
                    label: 'الأحاديث النبوية',
                    subtitle: 'الأربعين النووية بالشرح',
                    gradientColors: [const Color(0xFF114B43), const Color(0xFF004D40)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())),
                  ),
                  _buildMainButton(
                    icon: Icons.fingerprint_rounded,
                    label: 'المسبحة الذكية',
                    subtitle: 'عداد الأذكار المطور',
                    gradientColors: [const Color(0xFF2E5B3E), const Color(0xFF1E3D29)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeCard(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: isDark
              ? [colorScheme.surface, colorScheme.surface.withOpacity(0.7)]
              : [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            top: -20,
            child: Icon(
              Icons.mosque_rounded,
              size: 150,
              color: (isDark ? colorScheme.primary : Colors.white).withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: isDark ? colorScheme.primary : colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'توقيت مكة المكرمة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.access_time_filled_rounded,
                      color: isDark ? colorScheme.primary : colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _currentTime,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: isDark ? colorScheme.primary : Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black12 : Colors.black26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: isDark ? colorScheme.primary : colorScheme.secondary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _hijriDate,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? colorScheme.onSurface : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
