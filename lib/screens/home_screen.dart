import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nafahat/main.dart';
import 'package:nafahat/providers/settings_provider.dart';
import 'package:nafahat/screens/settings_screen.dart'; 
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
  
  int _timeCardStyleIndex = 0; 

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
    if (!mounted) return;
    
    // جلب الإعدادات لمعرفة تنسيق الوقت (12 أو 24)
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final makkahTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    
    // تطبيق التنسيق بناءً على الإعدادات
    final timeFormat = DateFormat(settings.is24HourFormat ? 'HH:mm' : 'hh:mm a', 'ar');
    
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

  String _getGreeting() {
    final hour = DateTime.now().toUtc().add(const Duration(hours: 3)).hour;
    if (hour >= 5 && hour < 12) return 'صباح مبارك';
    if (hour >= 12 && hour < 16) return 'طاب يومكم';
    if (hour >= 16 && hour < 20) return 'مساء الخيرات';
    return 'ليلة هانئة';
  }

  @override
  Widget build(BuildContext context) {
    // استخدمنا Consumer ليتحدث الوقت فور تغيير التنسيق في الإعدادات
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
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
                color: colorScheme.primary,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              // زر الإعدادات
              IconButton(
                icon: Icon(Icons.settings_rounded, color: colorScheme.primary),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // تم تصحيح الخطأ هنا (تم استبدال themeMode بـ isDark)
                colors: isDark
                    ? [colorScheme.surface, const Color(0xFF0F1410)]
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
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                        _buildMiniThemeSwitcher(colorScheme, isDark),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildCustomizableTimeCard(colorScheme, isDark),
                    const SizedBox(height: 28),
                    
                    Text(
                      'الخدمات الإسلامية',
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
                      subtitle: 'تصفح سور وآيات الذكر الحكيم',
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
                          subtitle: 'تحديد حي للموقع والتوقيت',
                          baseColor: colorScheme.secondary,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
                        ),
                        _buildGridMenuCard(
                          icon: Icons.auto_stories_rounded,
                          label: 'الأحاديث النبوية',
                          subtitle: 'الأربعين النووية بالشرح',
                          baseColor: const Color(0xFF114B43),
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())),
                        ),
                        _buildGridMenuCard(
                          icon: Icons.fingerprint_rounded,
                          label: 'المسبحة',
                          subtitle: 'عداد الأذكار المرن',
                          baseColor: const Color(0xFF2E5B3E),
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen())),
                        ),
                        _buildGridMenuCard(
                          icon: Icons.emoji_events_rounded,
                          label: 'هِمَمْ',
                          subtitle: 'تحديات واختبارات',
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
    );
  }

  Widget _buildMiniThemeSwitcher(ColorScheme colorScheme, bool isDark) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentMode, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: colorScheme.primary.withOpacity(0.05)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _miniThemeIcon(ThemeMode.light, Icons.wb_sunny_rounded, currentMode, colorScheme),
              _miniThemeIcon(ThemeMode.dark, Icons.nightlight_round, currentMode, colorScheme),
              _miniThemeIcon(ThemeMode.system, Icons.hdr_auto_rounded, currentMode, colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _miniThemeIcon(ThemeMode mode, IconData icon, ThemeMode currentMode, ColorScheme colorScheme) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => appThemeNotifier.value = mode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildCustomizableTimeCard(ColorScheme colorScheme, bool isDark) {
    return Stack(
      children: [
        _buildSelectedTimeCardStyle(colorScheme, isDark),
        
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.palette_outlined, color: Colors.white, size: 20),
              tooltip: 'تغيير المظهر',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              onSelected: (index) {
                setState(() {
                  _timeCardStyleIndex = index;
                });
              },
              itemBuilder: (context) => [
                _buildPopupItem(0, 'النمط الكلاسيكي'),
                _buildPopupItem(1, 'النمط المركزي'),
                _buildPopupItem(2, 'النمط المدمج'),
                _buildPopupItem(3, 'النمط الخفيف'),
                _buildPopupItem(4, 'النمط الذهبي'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<int> _buildPopupItem(int value, String text) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w600)),
          if (_timeCardStyleIndex == value)
            const Icon(Icons.check_circle, size: 18, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildSelectedTimeCardStyle(ColorScheme colorScheme, bool isDark) {
    switch (_timeCardStyleIndex) {
      case 0: return _timeCardStyle0(colorScheme, isDark);
      case 1: return _timeCardStyle1(colorScheme, isDark);
      case 2: return _timeCardStyle2(colorScheme, isDark);
      case 3: return _timeCardStyle3(colorScheme, isDark);
      case 4: return _timeCardStyle4(colorScheme, isDark);
      default: return _timeCardStyle0(colorScheme, isDark);
    }
  }

  Widget _timeCardStyle0(ColorScheme colorScheme, bool isDark) {
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              left: -20,
              top: -20,
              child: Icon(Icons.mosque_rounded, size: 160, color: Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars_rounded, size: 18, color: colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text('توقيت مكة المكرمة', 
                        style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_currentTime, 
                    style: GoogleFonts.ibmPlexSansArabic(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _timeCardStyle1(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark ? const Color(0xFF1E1E1E) : colorScheme.primary,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(_currentTime, style: GoogleFonts.ibmPlexSansArabic(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _timeCardStyle2(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark ? const Color(0xFF252A28) : const Color(0xFF123524),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الوقت الآن', style: GoogleFonts.ibmPlexSansArabic(color: Colors.white54, fontSize: 13)),
                Text(_currentTime, style: GoogleFonts.ibmPlexSansArabic(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
          Container(height: 50, width: 1.5, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('التاريخ الهجري', style: GoogleFonts.ibmPlexSansArabic(color: Colors.white54, fontSize: 13)),
                Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeCardStyle3(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withOpacity(0.4), width: 2),
        color: isDark ? Colors.transparent : Colors.white.withOpacity(0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mosque, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(_currentTime, style: GoogleFonts.ibmPlexSansArabic(fontSize: 34, fontWeight: FontWeight.w900, color: isDark ? Colors.white : colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _timeCardStyle4(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1C2833), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37))),
          const SizedBox(height: 12),
          Text(_currentTime, style: GoogleFonts.ibmPlexSansArabic(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          Text('بتوقيت مكة المكرمة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: Colors.white54)),
        ],
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
