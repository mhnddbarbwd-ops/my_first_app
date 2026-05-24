import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/prayer_time_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: BackButton(color: colorScheme.primary),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // قسم الوقت
          _buildSectionTitle('الوقت والتاريخ', colorScheme),
          _buildCard(
            context: context,
            child: SwitchListTile(
              title: Text(
                'تنسيق 24 ساعة',
                style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'استخدام تنسيق 24 ساعة بدلاً من 12 ساعة',
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              activeColor: colorScheme.primary,
              activeTrackColor: colorScheme.primary.withOpacity(0.3),
              value: settings.is24HourFormat,
              onChanged: (val) => settings.toggleTimeFormat(val),
            ),          ),

          // قسم الأذكار
          _buildSectionTitle('التذكير بالأذكار', colorScheme),
          _buildCard(
            context: context,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'التذكير بالصلاة على النبي',
                    style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'تنبيه صوتي ونصي للصلاة على النبي',
                    style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  activeColor: colorScheme.primary,
                  activeTrackColor: colorScheme.primary.withOpacity(0.3),
                  value: settings.prophetReminderEnabled,
                  onChanged: (val) => settings.toggleProphetReminder(val),
                ),
                if (settings.prophetReminderEnabled)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'معدل التذكير:',
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 13),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: settings.prophetReminderInterval,
                              style: GoogleFonts.ibmPlexSansArabic(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              items: const [
                                DropdownMenuItem(value: 30, child: Text('كل نصف ساعة')),
                                DropdownMenuItem(value: 60, child: Text('كل ساعة')),
                                DropdownMenuItem(value: 120, child: Text('كل ساعتين')),                              ],
                              onChanged: (val) {
                                if (val != null) settings.setProphetInterval(val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // قسم الصلاة والأذان
          _buildSectionTitle('تنبيهات الصلاة والأذان', colorScheme),
          _buildCard(
            context: context,
            child: Column(
              children: [
                // اختيار المؤذن - تصميم مميز
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.volume_up, color: colorScheme.primary, size: 22),
                  ),
                  title: Text(
                    'صوت المؤذن',
                    style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    settings.selectedMuazzin,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 13,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_forward_ios, color: colorScheme.primary, size: 14),
                  ),                  onTap: () => _showMuazzinDialog(context, settings),
                ),
                const Divider(height: 24),
                
                // قائمة تنبيهات الصلاة بتصميم شبكي أنيق
                Column(
                  children: settings.prayerNotifications.keys.map((prayer) {
                    final value = settings.prayerNotifications[prayer] ?? false;
                    return _buildPrayerToggle(prayer, value, settings, colorScheme);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة أنيقة مع ظل خفيف
  Widget _buildCard({required BuildContext context, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // عنوان القسم بتصميم مميز
  Widget _buildSectionTitle(String title, ColorScheme color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(2),            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color.primary,
            ),
          ),
        ],
      ),
    );
  }

  // عنصر تبديل الصلاة بتصميم شبكي
  Widget _buildPrayerToggle(String prayer, bool value, SettingsProvider settings, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value ? colorScheme.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? colorScheme.primary.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _getPrayerIcon(prayer),
                  size: 20,
                  color: value ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Text(
                  'أذان $prayer',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                    color: value ? colorScheme.primary : null,
                  ),
                ),
              ],
            ),            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: value,
                activeColor: colorScheme.primary,
                activeTrackColor: colorScheme.primary.withOpacity(0.3),
                onChanged: (val) {
                  if (val != null) {
                    _togglePrayerNotification(prayer, val, settings);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // أيقونة مميزة لكل صلاة
  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'الفجر':
        return Icons.nightlight_round;
      case 'الشروق':
        return Icons.wb_sunny;
      case 'الظهر':
        return Icons.light_mode;
      case 'العصر':
        // ✅ تم التعديل: partly_cloudy_day غير موجود، استبدلناه بـ cloud_queue
        return Icons.cloud_queue;
      case 'المغرب':
        return Icons.nights_stay;
      case 'العشاء':
        return Icons.star;
      default:
        return Icons.access_time;
    }
  }

  // تبديل إشعار الصلاة مع إعادة الجدولة
  Future<void> _togglePrayerNotification(String prayer, bool value, SettingsProvider settings) async {
    await settings.togglePrayerNotification(prayer, value);
    await PrayerTimeService().reschedule();
  }

  // نافذة اختيار المؤذن بتصميم راقي
  void _showMuazzinDialog(BuildContext context, SettingsProvider settings) {
    final colorScheme = Theme.of(context).colorScheme;
        showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // رأس النافذة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'اختر صوت المؤذن',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.pop(ctx),
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // قائمة المؤذنين
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: settings.muazzins.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final muazzin = settings.muazzins[index];
                    final isSelected = settings.selectedMuazzin == muazzin;
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await settings.setMuazzin(muazzin);
                          await PrayerTimeService().reschedule();
                          
                          if (ctx.mounted) {                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'تم اختيار $muazzin وتحديث الإشعارات',
                                        style: GoogleFonts.ibmPlexSansArabic(),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? colorScheme.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(Icons.check, size: 14, color: colorScheme.primary)
                                    : null,
                              ),
                              const SizedBox(width: 14),                              Expanded(
                                child: Text(
                                  muazzin,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? colorScheme.primary : null,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.volume_up, size: 18, color: colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'تم الاختيار',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}