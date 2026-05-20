import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/main.dart'; // لاستيراد themeNotifier
import 'package:nafahat/screens/quran_screen.dart';
import 'package:nafahat/screens/tasbih_screen.dart';
import 'package:nafahat/screens/hadith_screen.dart';
import 'package:nafahat/screens/prayer_times_screen.dart';

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
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'نَـفَـحَـات',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: 1.2,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم أزرار التحكم بالثيم الثلاثية الاحترافية
              Text(
                'مظهر التطبيق',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 10),
              _buildThemeSelector(context),
              const SizedBox(height: 24),
              
              _buildDateTimeCard(colorScheme, isDark),
              const SizedBox(height: 32),
              Text(
                'الخدمات والمميزات الإسلامية',
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
                    gradientColors: const [Color(0xFF0B3C18), Color(0xFF1B5E20)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen())),
                  ),
                  _buildMainButton(
                    icon: Icons.mosque_rounded,
                    label: 'مواقيت ومؤشرات',
                    subtitle: 'الصلاة والموقع الفعلي',
                    gradientColors: const [Color(0xFFC5A880), Color(0xFF9E7E50)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
                  ),
                  _buildMainButton(
                    icon: Icons.book_rounded,
                    label: 'الأحاديث النبوية',
                    subtitle: 'الأربعين النووية كاملة',
                    gradientColors: const [Color(0xFF114B43), Color(0xFF004D40)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())),
                  ),
                  _buildMainButton(
                    icon: Icons.fingerprint_rounded,
                    label: 'المسبحة الذكية',
                    subtitle: 'عداد الأذكار المطور',
                    gradientColors: const [Color(0xFF2E5B3E), Color(0xFF1E3D29)],
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

  Widget _buildThemeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              _buildThemeOption(ThemeMode.light, Icons.wb_sunny_rounded, 'فاتح', currentMode, colorScheme),
              _buildThemeOption(ThemeMode.dark, Icons.nightlight_round, 'مظلم', currentMode, colorScheme),
              _buildThemeOption(ThemeMode.system, Icons.settings_suggest_rounded, 'تلقائي', currentMode, colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(ThemeMode mode, IconData icon, String label, ThemeMode currentMode, ColorScheme colorScheme) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => themeNotifier.value = mode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6), size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
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
                        Icon(Icons.location_on_rounded, size: 18, color: isDark ? colorScheme.primary : colorScheme.secondary),
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
                    Icon(Icons.access_time_filled_rounded, color: isDark ? colorScheme.primary : colorScheme.secondary),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _currentTime,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: isDark ? colorScheme.primary : Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18, color: isDark ? colorScheme.primary : colorScheme.secondary),
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
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(color: gradientColors[0].withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6)),
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
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
