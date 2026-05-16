import 'package:flutter/material.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/services/goals_service.dart';
import 'package:hive/hive.dart';
import 'package:my_first_app/models/user_profile.dart';
import 'package:my_first_app/models/user_activity.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;
  final bool isDarkMode;
  final String language;
  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
    required this.onLanguageToggle,
    required this.isDarkMode,
    required this.language,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _ringtone = 'افتراضي';
  String _unit = 'متري';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsBox = Hive.box('settingsBox');
    setState(() {
      _ringtone = settingsBox.get('ringtone', defaultValue: 'افتراضي') ?? 'افتراضي';
      _unit = settingsBox.get('unit', defaultValue: 'متري') ?? 'متري';
    });
  }

  void _saveSetting(String key, dynamic value) {
    final settingsBox = Hive.box('settingsBox');
    settingsBox.put(key, value);
    setState(() {});
  }

  void _resetAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text('سيتم حذف جميع بيانات النشاط والأهداف والملف الشخصي. لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // حذف جميع الصناديق
              Hive.box<UserActivity>('activityBox').clear();
              Hive.box<UserProfile>('profileBox').clear();
              Hive.box('settingsBox').clear();
              // إعادة تهيئة الأهداف الافتراضية
              GoalsService().recalculateFromProfile();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف جميع البيانات بنجاح')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // المظهر
          _buildSectionTitle('المظهر'),
          Card(
            elevation: 0,
            color: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('الوضع الليلي'),
                  subtitle: Text(widget.isDarkMode ? 'داكن' : 'فاتح'),
                  value: widget.isDarkMode,
                  onChanged: (_) => widget.onThemeToggle(),
                  secondary: Icon(
                    widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('اللغة'),
                  subtitle: Text(widget.language == 'ar' ? 'العربية' : 'English'),
                  onTap: widget.onLanguageToggle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // الصوت والتنبيهات
          _buildSectionTitle('الصوت والتنبيهات'),
          Card(
            elevation: 0,
            color: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.music_note),
                  title: const Text('نغمة المنبه'),
                  subtitle: Text(_ringtone),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('اختر النغمة'),
                        children: ['افتراضي', 'لحن الصباح', 'نبضات', 'هادئة'].map((tone) {
                          return SimpleDialogOption(
                            onPressed: () {
                              _saveSetting('ringtone', tone);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم تعيين النغمة: $tone')),
                              );
                            },
                            child: Text(tone),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.vibration),
                  title: const Text('الاهتزاز'),
                  subtitle: const Text('عند المنبهات والإشعارات'),
                  trailing: Switch(
                    value: true,
                    onChanged: (val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'تم تفعيل الاهتزاز' : 'تم تعطيل الاهتزاز')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // الوحدات
          _buildSectionTitle('الوحدات والقياسات'),
          Card(
            elevation: 0,
            color: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('وحدة القياس'),
              subtitle: Text(_unit == 'متري' ? 'متري (كم/كجم)' : 'إمبراطوري (ميل/رطل)'),
              onTap: () {
                setState(() {
                  _unit = _unit == 'متري' ? 'إمبراطوري' : 'متري';
                  _saveSetting('unit', _unit);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تغيير الوحدة إلى $_unit')),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // البيانات
          _buildSectionTitle('البيانات والخصوصية'),
          Card(
            elevation: 0,
            color: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('تصدير البيانات'),
                  subtitle: const Text('تنزيل سجل نشاطك'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قادم قريباً: تصدير البيانات')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('حذف جميع البيانات', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('إعادة ضبط التطبيق بالكامل'),
                  onTap: _resetAllData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // معلومات التطبيق
          _buildSectionTitle('حول التطبيق'),
          Card(
            elevation: 0,
            color: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('فِـز'),
                  subtitle: const Text('الإصدار 1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('تم بناؤه بـ Flutter & Dart'),
                  subtitle: const Text('تطبيق صحي متكامل'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}