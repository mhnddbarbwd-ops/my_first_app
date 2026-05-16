import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_first_app/models/alarm_model.dart';
import 'package:my_first_app/services/alarm_service.dart';
import 'package:my_first_app/widgets/add_alarm_sheet.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  void _showAddAlarmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAlarmSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // هذا هو السحر: Provider.of سيعيد بناء هذه الـ Widget تلقائيًا
    // كلما استدعينا notifyListeners() في AlarmService
    final alarmService = Provider.of<AlarmService>(context);
    final alarms = alarmService.alarms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المنبهات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 30),
            onPressed: () => _showAddAlarmSheet(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_paused_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text('لا توجد منبهات'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAlarmSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('أضف منبهًا جديدًا'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Dismissible(
                  key: Key(alarm.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => alarmService.deleteAlarm(alarm.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Theme.of(context).cardTheme.color,
                    child: ListTile(
                      title: Text(alarm.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: Text(alarm.category,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                      leading: Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary),
                      trailing: Switch(
                        value: alarm.isActive,
                        onChanged: (val) {
                          alarmService.toggleAlarm(alarm, val);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}