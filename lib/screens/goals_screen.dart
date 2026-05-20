import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/models/reading_goal.dart';
import 'package:nafahat/services/goals_service.dart';
import 'package:nafahat/services/reminder_service.dart';
import 'package:uuid/uuid.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalsService _goalsService = GoalsService();
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = 'khatm';
  int _totalPages = 604;
  int _durationDays = 30;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final goals = _goalsService.goals;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تحدي ختم القرآن',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context, colorScheme),
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories_rounded, size: 64, color: colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد أهداف حالية',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أضف هدفاً جديداً لتبدأ رحلتك مع القرآن',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildGoalCard(goal, colorScheme),
                );
              },
            ),
    );
  }

  Widget _buildGoalCard(ReadingGoal goal, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = goal.progress;
    final remainingDays = goal.endDate.difference(DateTime.now()).inDays;
    final pagesPerDay = (goal.remainingPages / (remainingDays > 0 ? remainingDays : 1)).ceil();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark ? colorScheme.surface.withOpacity(0.5) : colorScheme.surface,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.flag_rounded, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ينتهي في ${goal.endDate.day}/${goal.endDate.month}/${goal.endDate.year}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _goalsService.deleteGoal(goal.id).then((_) => setState(() {})),
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.completedPages} / ${goal.totalPages} صفحة',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.primary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.today_rounded, '$remainingDays', 'يوم متبقي'),
                _buildStatItem(Icons.menu_book_rounded, '$pagesPerDay', 'صفحة/يوم'),
                if (goal.reminderEnabled) _buildStatItem(Icons.notifications_active_rounded, goal.reminderTime, 'تذكير'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'تحديث التقدم',
                  color: colorScheme.primary,
                  onTap: () => _showUpdateProgressDialog(goal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  icon: goal.reminderEnabled ? Icons.notifications_off_rounded : Icons.notifications_rounded,
                  label: goal.reminderEnabled ? 'إيقاف التذكير' : 'تفعيل التذكير',
                  color: goal.reminderEnabled ? Colors.orange : colorScheme.secondary,
                  onTap: () => _toggleReminder(goal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'إضافة تحدي جديد',
                  style: GoogleFonts.ibmPlexSansArabic(fontSize: 22, fontWeight: FontWeight.w900, color: colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم التحدي',
                    hintText: 'مثلاً: ختم القرآن في رمضان',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: Icon(Icons.edit_rounded, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildOptionChip('khatm', 'ختم القرآن', _selectedType, setModalState),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildOptionChip('hifz', 'حفظ', _selectedType, setModalState),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildOptionChip('custom', 'مخصص', _selectedType, setModalState),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'عدد الصفحات'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _totalPages = int.tryParse(v) ?? 604,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'المدة (أيام)'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _durationDays = int.tryParse(v) ?? 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: Text('تفعيل التذكير اليومي', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14)),
                        value: _reminderEnabled,
                        onChanged: (val) => setModalState(() => _reminderEnabled = val),
                      ),
                    ),
                    if (_reminderEnabled)
                      TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(context: ctx, initialTime: _reminderTime);
                          if (time != null) setModalState(() => _reminderTime = time);
                        },
                        child: Text(_reminderTime.format(ctx)),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) return;
                    final goal = ReadingGoal(
                      id: const Uuid().v4(),
                      name: _nameController.text.trim(),
                      type: _selectedType,
                      totalPages: _totalPages,
                      startDate: DateTime.now(),
                      endDate: DateTime.now().add(Duration(days: _durationDays)),
                      reminderEnabled: _reminderEnabled,
                      reminderTime: '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                    );
                    _goalsService.addGoal(goal).then((_) {
                      if (_reminderEnabled) {
                        ReminderService().scheduleDailyReminder(goal);
                      }
                      setState(() {});
                      Navigator.pop(ctx);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text('بدء التحدي', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChip(String value, String label, String selected, StateSetter setModalState) {
    final isSelected = selected == value;
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.w600)),
      selected: isSelected,
      onSelected: (_) => setModalState(() => _selectedType = value),
      selectedColor: colorScheme.primary.withOpacity(0.15),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  void _showUpdateProgressDialog(ReadingGoal goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تحديث التقدم', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'عدد الصفحات المكتملة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final pages = int.tryParse(controller.text) ?? 0;
              if (pages > 0) {
                goal.completedPages = pages;
                _goalsService.updateGoal(goal).then((_) => setState(() {}));
                Navigator.pop(ctx);
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _toggleReminder(ReadingGoal goal) {
    goal.reminderEnabled = !goal.reminderEnabled;
    _goalsService.updateGoal(goal).then((_) {
      if (goal.reminderEnabled) {
        ReminderService().scheduleDailyReminder(goal);
      } else {
        ReminderService().cancelReminder(goal.id);
      }
      setState(() {});
    });
  }
}