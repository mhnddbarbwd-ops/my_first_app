import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/main.dart';
import 'package:nafahat/screens/quran_screen.dart';
import 'package:nafahat/screens/tasbih_screen.dart';
import 'package:nafahat/screens/hadith_screen.dart';
import 'package:nafahat/screens/prayer_times_screen.dart';
import 'package:nafahat/screens/goals_screen.dart';  // 🆕 استيراد صفحة التحديات

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'نَـفَـحَـات',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: 1.2,
            color: isDark ? colorScheme.primary : colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? colorScheme.primary : colorScheme.onPrimary,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [colorScheme.surface, colorScheme.background]
                : [colorScheme.primary.withOpacity(0.1), colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // لوحة التحكم بالثيمات الثلاثية المخصصة الاحترافية
                  Text(
                    'مظهر التطبيق الديناميكي',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeSwitcherControl(context, colorScheme, isDark),
                  const SizedBox(height: 28),

                  _buildModernDateTimeCard(colorScheme, isDark),
                  const SizedBox(height: 32),

                  Text(
                    'الخدمات الإسلامية الفاخرة',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.92,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    children: [
                      _buildMenuCard(
                        icon: Icons.menu_book_rounded,
                        label: 'القرآن الكريم',
                        subtitle: 'تصفح، فهرس وبحث ذكي',
                        colors: isDark
                            ? [colorScheme.primary.withOpacity(0.8), colorScheme.primary]
                            : [const Color(0xFF0B3C18), const Color(0xFF1B5E20)],
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen())),
                      ),
                      _buildMenuCard(
                        icon: Icons.location_on_rounded,
                        label: 'مواقيت الصلاة',
                        subtitle: 'تحديد الموقع الحي والتوقيت',
                        colors: isDark
                            ? [colorScheme.secondary.withOpacity(0.8), colorScheme.secondary]
                            : [const Color(0xFFC5A880), const Color(0xFF9E7E50)],
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
                      ),
                      _buildMenuCard(
                        icon: Icons.auto_stories_rounded,
                        label: 'الأحاديث النبوية',
                        subtitle: 'الأربعين النووية بالشرح كاملة',
                        colors: isDark
                            ? [const Color(0xFF114B43), const Color(0xFF004D40)]
                            : [const Color(0xFF114B43), const Color(0xFF004D40)],
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())),
                      ),
                      _buildMenuCard(
                        icon: Icons.fingerprint_rounded,
                        label: 'المسبحة الذكية',
                        subtitle: 'عداد الأذكار المطور المرن',
                        colors: isDark
                            ? [const Color(0xFF2E5B3E), const Color(0xFF1E3D29)]
                            : [const Color(0xFF2E5B3E), const Color(0xFF1E3D29)],
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen())),
                      ),
                      // 🆕 بطاقة تحدي ختم القرآن
                      _buildMenuCard(
                        icon: Icons.flag_rounded,
                        label: 'تحدي ختم القرآن',
                        subtitle: 'حدد هدفك وتابع إنجازك',
                        colors: isDark
                            ? [const Color(0xFF3D5A5C), const Color(0xFF1F3A3C)]
                            : [const Color(0xFF2E5B3E), const Color(0xFF1E3D29)],
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitcherControl(BuildContext context, ColorScheme colorScheme, bool isDark) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentMode, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface.withOpacity(0.5) : colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
          ),
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              _buildThemeItem(ThemeMode.light, Icons.wb_sunny_rounded, 'فاتح', currentMode, colorScheme),
              _buildThemeItem(ThemeMode.dark, Icons.dark_mode_rounded, 'مظلم', currentMode, colorScheme),
              _buildThemeItem(ThemeMode.system, Icons.hdr_auto_rounded, 'تلقائي', currentMode, colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeItem(ThemeMode mode, IconData icon, String label, ThemeMode currentMode, ColorScheme colorScheme) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => appThemeNotifier.value = mode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDateTimeCard(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: isDark
              ? [colorScheme.surface, colorScheme.surface.withOpacity(0.8)]
              : [colorScheme.primary, colorScheme.primary.withOpacity(0.88)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            top: -30,
            child: Icon(
              Icons.mosque_rounded,
              size: 180,
              color: (isDark ? colorScheme.primary : Colors.white).withOpacity(0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 18, color: colorScheme.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'توقيت مكة المكرمة الأوتوماتيكي',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.av_timer_rounded, color: colorScheme.secondary),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _currentTime,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: isDark ? colorScheme.primary : Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.black38,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 18, color: colorScheme.secondary),
                      const SizedBox(width: 10),
                      Text(
                        _hijriDate,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
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

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
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
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.3,
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
