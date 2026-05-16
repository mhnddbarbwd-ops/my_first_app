import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_first_app/screens/alarms_screen.dart';
import 'package:my_first_app/screens/health_screen.dart';
import 'package:my_first_app/screens/activity_screen.dart';
import 'package:my_first_app/screens/goals_screen.dart';
import 'package:my_first_app/screens/labs_screen.dart';
import 'package:my_first_app/screens/rive_demo_screen.dart';
import 'package:my_first_app/screens/settings_screen.dart';
import 'package:my_first_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;
  final bool isDarkMode;
  final String language;
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.onLanguageToggle,
    required this.isDarkMode,
    required this.language,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const AlarmsScreen(),
      const HealthScreen(),
      const ActivityScreen(),
      const GoalsScreen(),
      const LabsScreen(),
      const RiveDemoScreen(),
      SettingsScreen(
        onThemeToggle: widget.onThemeToggle,
        onLanguageToggle: widget.onLanguageToggle,
        isDarkMode: widget.isDarkMode,
        language: widget.language,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('فِـز', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            onPressed: widget.onThemeToggle,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.alarm_rounded, 'المنبهات', 0),
                    _buildNavItem(Icons.favorite_rounded, 'الصحة', 1),
                    _buildNavItem(Icons.auto_graph_rounded, 'النشاط', 2),
                    _buildNavItem(Icons.flag_rounded, 'أهدافي', 3),
                    _buildNavItem(Icons.science_rounded, 'المختبر', 4),
                    _buildNavItem(Icons.settings_rounded, 'الإعدادات', 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 10 : 6,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}