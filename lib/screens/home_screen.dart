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
import 'package:nafahat/screens/himam_screen.dart';

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
    if (mounted) {
      setState(() {
        _currentTime = timeFormat.format(makkahTime);
        _hijriDate = '${today.hDay} ${months[today.hMonth - 1]} ${today.hYear} هـ';
      });
    }
  }

  String _getDynamicGreeting() {
    final hour = DateTime.now().toUtc().add(const Duration(hours: 3)).hour;
    if (hour >= 5 && hour < 12) return 'صباحٌ مبارك بذكر الله';
    if (hour >= 12 && hour < 16) return 'طاب يومكم بالطاعات';
    if (hour >= 16 && hour < 20) return 'مساءٌ عامرٌ بالخيرات';
    return 'ليلةٌ هانئة في حفظ الرحمن';
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
            fontSize: 26,
            letterSpacing: 1.5,
            color: isDark ? colorScheme.primary : colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [colorScheme.surface, isDark ? const Color(0xFF0F1410) : colorScheme.surface]
                : [colorScheme.primary.withOpacity(0.06), colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDynamicGreeting(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? colorScheme.primary : colorScheme.primary,
                          ),
                        ),
                        Text(
                          'مظهر التطبيق الذكي',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.spa_rounded, color: colorScheme.secondary, size: 28),
                  ],
                ),
                const SizedBox(height: 12),
                _buildThemeSwitcherControl(context, colorScheme, isDark),
                const SizedBox(height: 24),
                _buildModernDateTimeCard(colorScheme, isDark),
                const SizedBox(height: 28),
                Text(
                  'الواجهة الإسلامية الفاخرة',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeaturedMenuCard(
                  context: context,
                  icon: Icons.menu_book_rounded,
                  label: 'القرآن الكريم',
                  subtitle: 'تصفح سور وآيات الذكر الحكيم بفهرس وبحث ذكي متطور',
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen())),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildGridMenuCard(
                      icon: Icons.access_time_filled_rounded,
                      label: 'مواقيت الصلاة',
                      subtitle: 'تحديد حي للموقع والتوقيت الدقيق',
                      baseColor: colorScheme.secondary,
                      colorScheme: colorScheme,
                      isDark: isDark,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
                    ),
                    _buildGridMenuCard(
                      icon: Icons.auto_stories_rounded,
                      label: 'الأحاديث النبوية',
                      subtitle: 'الأربعين النووية بالشرح والبيان',
                      baseColor: const Color(0xFF114B43),
                      colorScheme: colorScheme,
                      isDark: isDark,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())),
                    ),
                    _buildGridMenuCard(
                      icon: Icons.fingerprint_rounded,
                      label: 'المسبحة الذكية',
                      subtitle: 'عداد الأذكار المطور المرن والمعاصر',
                      baseColor: const Color(0xFF2E5B3E),
                      colorScheme: colorScheme,
                      isDark: isDark,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen())),
                    ),
                    _buildGridMenuCard(
                      icon: Icons.emoji_events_rounded,
                      label: 'هِمَمْ المتكاملة',
                      subtitle: 'تحديات، اختبارات وأوسمة تشجيعية',
                      baseColor: isDark ? const Color(0xFF5C3D6E) : const Color(0xFF6A1B9A),
                      colorScheme: colorScheme,
                      isDark: isDark,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HimamScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
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
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: colorScheme.primary.withOpacity(0.05)),
          ),
          padding: const EdgeInsets.all(5),
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.5),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [colorScheme.surface, colorScheme.primary.withOpacity(0.15)]
              : [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: colorScheme.primary.withOpacity(isDark ? 0.1 : 0.0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              left: -20,
              top: -20,
              child: Icon(
                Icons.mosque_rounded,
                size: 160,
                color: (isDark ? colorScheme.primary : Colors.white).withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.stars_rounded, size: 18, color: colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'توقيت مكة المكرمة الأوتوماتيكي',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.schedule_rounded, color: colorScheme.secondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentTime,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? colorScheme.primary : Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          _hijriDate,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.white,
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
      ),
    );
  }

  Widget _buildFeaturedMenuCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required ColorScheme colorScheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark 
              ? [colorScheme.primary.withOpacity(0.2), colorScheme.primary.withOpacity(0.3)]
              : [const Color(0xFF0B3C18), const Color(0xFF165225)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3C18).withOpacity(isDark ? 0.1 : 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: isDark ? colorScheme.primary : Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: Colors.white.withOpacity(0.6), size: 28)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridMenuCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color baseColor,
    required ColorScheme colorScheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final finalGradient = isDark 
        ? [colorScheme.surface, baseColor.withOpacity(0.15)]
        : [baseColor, baseColor.withOpacity(0.85)];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: finalGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(isDark ? 0.05 : 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? colorScheme.primary.withOpacity(0.08) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? baseColor.withOpacity(0.15) : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: isDark ? baseColor : Colors.white, size: 24),
                ),
                const Spacer(),
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 11,
                    color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.white.withOpacity(0.8),
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
