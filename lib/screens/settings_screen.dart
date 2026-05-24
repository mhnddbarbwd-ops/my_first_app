import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, color: colorScheme.primary)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: BackButton(color: colorScheme.primary), // زر العودة
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // قسم الوقت
          _buildSectionTitle('الوقت والتاريخ', colorScheme),
          SwitchListTile(
            title: Text('تنسيق 24 ساعة', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
            subtitle: Text('استخدام تنسيق 24 ساعة بدلاً من 12 ساعة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 12)),
            activeColor: colorScheme.primary,
            value: settings.is24HourFormat,
            onChanged: (val) => settings.toggleTimeFormat(val),
          ),
          const Divider(),

          // قسم الأذكار
          _buildSectionTitle('التذكير بالأذكار', colorScheme),
          SwitchListTile(
            title: Text('التذكير بالصلاة على النبي', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
            subtitle: Text('تنبيه صوتي ونصي للصلاة على النبي', style: GoogleFonts.ibmPlexSansArabic(fontSize: 12)),
            activeColor: colorScheme.primary,
            value: settings.prophetReminderEnabled,
            onChanged: (val) => settings.toggleProphetReminder(val),
          ),
          if (settings.prophetReminderEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('معدل التذكير:', style: GoogleFonts.ibmPlexSansArabic()),
                  DropdownButton<int>(
                    value: settings.prophetReminderInterval,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 30, child: Text('كل نصف ساعة')),
                      DropdownMenuItem(value: 60, child: Text('كل ساعة')),
                      DropdownMenuItem(value: 120, child: Text('كل ساعتين')),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setProphetInterval(val);
                    },
                  ),
                ],
              ),
            ),
          const Divider(),

          // قسم الصلاة
          _buildSectionTitle('تنبيهات الصلاة والأذان', colorScheme),
          ListTile(
            title: Text('صوت المؤذن', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
            subtitle: Text(settings.selectedMuazzin, style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.primary)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // مستقبلاً تفتح نافذة لاختيار المؤذن
            },
          ),
          const SizedBox(height: 10),
          ...settings.prayerNotifications.keys.map((prayer) {
            return CheckboxListTile(
              title: Text('أذان $prayer', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
              activeColor: colorScheme.primary,
              value: settings.prayerNotifications[prayer],
              onChanged: (val) {
                if (val != null) settings.togglePrayerNotification(prayer, val);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme color) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.bold, color: color.primary),
      ),
    );
  }
}
