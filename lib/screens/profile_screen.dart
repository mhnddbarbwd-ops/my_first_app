import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_first_app/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String _gender = 'ذكر';
  int _age = 25;
  double _weight = 70.0;
  double _height = 170.0;
  bool _loading = true;

  late Box<UserProfile> _profileBox;

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box<UserProfile>('profileBox');
    _loadProfile();
  }

  void _loadProfile() {
    final profile = _profileBox.get('user', defaultValue: UserProfile());
    if (profile != null) {
      _nameController.text = profile.name;
      _gender = profile.gender;
      _age = profile.age;
      _weight = profile.weight;
      _height = profile.height;
    }
    setState(() => _loading = false);
  }

  void _saveProfile() {
    final profile = UserProfile(
      name: _nameController.text,
      gender: _gender,
      age: _age,
      weight: _weight,
      height: _height,
      profileComplete: true,
    );
    _profileBox.put('user', profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الملف الشخصي')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // اسم المستخدم
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // الجنس
            const Text('الجنس', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('ذكر'),
                  selected: _gender == 'ذكر',
                  onSelected: (val) => setState(() => _gender = 'ذكر'),
                  selectedColor: Colors.blue.shade100,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('أنثى'),
                  selected: _gender == 'أنثى',
                  onSelected: (val) => setState(() => _gender = 'أنثى'),
                  selectedColor: Colors.pink.shade100,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // العمر
            const Text('العمر', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 30),
                  onPressed: () => setState(() => _age = (_age - 1).clamp(1, 120)),
                ),
                Text('$_age', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 30),
                  onPressed: () => setState(() => _age = (_age + 1).clamp(1, 120)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // الوزن
            const Text('الوزن (كجم)', style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _weight,
              min: 30, max: 200,
              divisions: 170,
              label: '${_weight.toInt()} كجم',
              onChanged: (val) => setState(() => _weight = val),
            ),
            Center(child: Text('${_weight.toInt()} كجم')),
            const SizedBox(height: 20),

            // الطول
            const Text('الطول (سم)', style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _height,
              min: 100, max: 250,
              divisions: 150,
              label: '${_height.toInt()} سم',
              onChanged: (val) => setState(() => _height = val),
            ),
            Center(child: Text('${_height.toInt()} سم')),
            const SizedBox(height: 40),

            // زر الحفظ
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}