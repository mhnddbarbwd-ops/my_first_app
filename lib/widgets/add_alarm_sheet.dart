import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:my_first_app/models/alarm_model.dart';
import 'package:my_first_app/services/alarm_service.dart';

class AddAlarmSheet extends StatefulWidget {
  const AddAlarmSheet({super.key});

  @override
  State<AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<AddAlarmSheet> {
  final _titleController = TextEditingController();
  String _category = 'عام';
  TimeOfDay _time = TimeOfDay.now();
  int _goal = 1;
  Color _selectedColor = const Color(0xFF006A6A);

  final List<Color> _colors = const [
    Color(0xFF006A6A),
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'رياضة', 'icon': Icons.directions_run},
    {'name': 'صحة', 'icon': Icons.favorite},
    {'name': 'عمل', 'icon': Icons.work},
    {'name': 'عام', 'icon': Icons.notifications},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('إلغاء',
                          style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('منبه جديد',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 24, fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 20),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'اسم المنبه',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                      prefixIcon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _time);
                    if (t != null) setState(() => _time = t);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الوقت', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        Text(_time.format(context),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text('الفئة', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _category == cat['name'];
                    return ChoiceChip(
                      label: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(cat['icon'], size: 18,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 4),
                        Text(cat['name'],
                            style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface)),
                      ]),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _category = cat['name']),
                      selectedColor: _selectedColor,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                Text('التكرار', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Row(
                  children: [1, 2, 5, 10].map((g) {
                    final selected = _goal == g;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$g',
                            style: TextStyle(
                                color: selected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface)),
                        selected: selected,
                        onSelected: (val) => setState(() => _goal = g),
                        selectedColor: _selectedColor,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text('لون المنبه', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: _colors.map((c) {
                    final selected = _selectedColor == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selected ? Border.all(color: Colors.white, width: 3) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال اسم المنبه')),
                      );
                      return;
                    }
                    final alarm = AlarmModel(
                      title: _titleController.text.trim(),
                      category: _category,
                      hour: _time.hour,
                      minute: _time.minute,
                      goal: _goal,
                    );
                    // استخدام الخدمة للإضافة بدلاً من دالة callback
                    Provider.of<AlarmService>(context, listen: false).addAlarm(alarm);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: _selectedColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('إضافة المنبه', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}