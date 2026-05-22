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
  
  // متغير لتخزين شكل بطاقة الوقت (من 0 إلى 4)
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
    final makkahTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    final timeFormat = DateFormat('hh:mm a', 'ar');
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

  String _getGreeting() {
    final hour = DateTime.now().toUtc().add(const Duration(hours: 3)).hour;
    if (hour >= 5 && hour < 12) return 'صباح مبارك';
    if (hour >= 12 && hour < 16) return 'طاب يومكم';
    if (hour >= 16 && hour < 20) return 'مساء الخيرات';
    return 'ليلة هانئة';
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
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.0,
            color: colorScheme.primary,
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
                ? [colorScheme.surface, const Color(0xFF121212)]
                : [colorScheme.primary.withOpacity(0.03), colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصف العلوي: الترحيب وزر المظهر الصغير جداً
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _getGreeting(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    _buildMiniThemeSwitcher(colorScheme, isDark),
                  ],
                ),
                const SizedBox(height: 24),
                
                // بطاقة الوقت القابلة للتخصيص
                _buildCustomizableTimeCard(colorScheme, isDark),
                const SizedBox(height: 30),
                
                Text(
                  'الخدمات الرئيسية',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                _buildFeaturedMenuCard(
                  context: context,
                  icon: Icons.menu_book_rounded,
                  label: 'القرآن الكريم',
                  subtitle: 'تلاوة، فهرس، وبحث في السور والآيات',
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen())),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.05,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildGridMenuCard(
                      icon: Icons.access_time_filled_rounded,
                      label: 'مواقيت الصلاة',
                      subtitle: 'تحديد أوقات الصلوات',
                      baseColor: colorScheme.secondary,
                      colorScheme: colorScheme,
                      isDark: isDark,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
                    ),
                    _buildGridMenuCard(
                      icon: Icons.auto_stories_rounded,
                      label: 'الأحاديث النبوية',
                      subtitle: 'الأربعين النووية',
                      baseColor: const Color(0xFF2A5C43),
                      colorScheme: colorScheme,
                      isDark: isDark,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())),
                    ),
                    _buildGridMenuCard(
                      icon: Icons.fingerprint_rounded,
                      label: 'المسبحة',
                      subtitle: 'عداد إلكتروني للأذكار',
                      baseColor: const Color(0xFF3B6E52),
                      colorScheme: colorScheme,
                      isDark: isDark,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen())),
                    ),
                    _buildGridMenuCard(
                      icon: Icons.emoji_events_rounded,
                      label: 'هِمَمْ',
                      subtitle: 'تحديات ومتابعة الإنجاز',
                      baseColor: const Color(0xFF6B427A),
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

  // مبدل المظهر (Theme Switcher) المصغر والاحترافي جداً
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
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

  // بطاقة الوقت المجمعة مع زر التخصيص
  Widget _buildCustomizableTimeCard(ColorScheme colorScheme, bool isDark) {
    return Stack(
      children: [
        // عرض البطاقة حسب النمط المختار
        _buildSelectedTimeCardStyle(colorScheme, isDark),
        
        // زر التخصيص (الإعدادات) في الزاوية
        Positioned(
          top: 8,
          left: 8,
          child: PopupMenuButton<int>(
            icon: Icon(Icons.palette_outlined, 
              color: _timeCardStyleIndex == 3 || _timeCardStyleIndex == 4 
                  ? colorScheme.primary 
                  : Colors.white70, 
              size: 20),
            tooltip: 'تغيير شكل البطاقة',
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
      ],
    );
  }

  PopupMenuItem<int> _buildPopupItem(int value, String text) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: GoogleFonts.ibmPlexSansArabic(fontSize: 14)),
          if (_timeCardStyleIndex == value)
            const Icon(Icons.check_circle, size: 16, color: Colors.green),
        ],
      ),
    );
  }

  // دالة تحويل بين الأشكال الخمسة للبطاقة
  Widget _buildSelectedTimeCardStyle(ColorScheme colorScheme, bool isDark) {
    switch (_timeCardStyleIndex) {
      case 0: return _timeCardStyle0(colorScheme, isDark); // النمط الكلاسيكي الأصلي المحسن
      case 1: return _timeCardStyle1(colorScheme, isDark); // مركزي وبسيط
      case 2: return _timeCardStyle2(colorScheme, isDark); // مدمج عمودي
      case 3: return _timeCardStyle3(colorScheme, isDark); // خفيف وبدون خلفية قوية
      case 4: return _timeCardStyle4(colorScheme, isDark); // ذهبي أنيق
      default: return _timeCardStyle0(colorScheme, isDark);
    }
  }

  // الشكل 0: الكلاسيكي
  Widget _timeCardStyle0(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [colorScheme.surface, colorScheme.primary.withOpacity(0.1)]
              : [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('توقيت مكة المكرمة', 
            style: GoogleFonts.ibmPlexSansArabic(color: isDark ? colorScheme.primary : Colors.white70, fontSize: 12)),
          const SizedBox(height: 10),
          Text(_currentTime, 
            style: GoogleFonts.ibmPlexSansArabic(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.white)),
          const SizedBox(height: 10),
          Text(_hijriDate, 
            style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, color: isDark ? Colors.white70 : Colors.white)),
        ],
      ),
    );
  }

  // الشكل 1: مركزي وبسيط
  Widget _timeCardStyle1(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1E1E1E) : colorScheme.primary,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(_currentTime, 
            style: GoogleFonts.ibmPlexSansArabic(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // الشكل 2: مدمج أفقي
  Widget _timeCardStyle2(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1B4235),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الوقت الآن', style: GoogleFonts.ibmPlexSansArabic(color: Colors.white54, fontSize: 12)),
              Text(_currentTime, style: GoogleFonts.ibmPlexSansArabic(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          Container(height: 40, width: 1, color: Colors.white24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('التاريخ الهجري', style: GoogleFonts.ibmPlexSansArabic(color: Colors.white54, fontSize: 12)),
              Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  // الشكل 3: خفيف Outline
  Widget _timeCardStyle3(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 1.5),
        color: isDark ? Colors.transparent : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mosque, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_currentTime, 
            style: GoogleFonts.ibmPlexSansArabic(fontSize: 34, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  // الشكل 4: ذهبي أنيق
  Widget _timeCardStyle4(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(_hijriDate, style: GoogleFonts.ibmPlexSansArabic(fontSize: 15, color: const Color(0xFFD4AF37))),
          const SizedBox(height: 8),
          Text(_currentTime, 
            style: GoogleFonts.ibmPlexSansArabic(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('بتوقيت مكة المكرمة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: Colors.white54)),
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
        borderRadius: BorderRadius.circular(20),
        color: isDark ? colorScheme.surface : const Color(0xFF14472A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark ? Border.all(color: colorScheme.primary.withOpacity(0.1)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: isDark ? colorScheme.primary : Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white54 : Colors.white54, size: 16)
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? colorScheme.surface : baseColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark ? Border.all(color: colorScheme.primary.withOpacity(0.1)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isDark ? baseColor : Colors.white, size: 28),
                const Spacer(),
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.white.withOpacity(0.8),
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
