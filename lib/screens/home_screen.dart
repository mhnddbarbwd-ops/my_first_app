import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nafahat/screens/quran_screen.dart';
import 'package:nafahat/screens/prayer_times_screen.dart';
import 'package:nafahat/screens/tasbih_screen.dart';
import 'package:nafahat/screens/hadith_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTime = '';
  String _hijriDate = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    HijriDate.setLocal('ar');
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _updateDateTime() {
    final makkahTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    final timeFormat = DateFormat('hh:mm:ss a', 'ar');
    final today = HijriDate.now();
    const months = ['محرم','صفر','ربيع الأول','ربيع الآخر','جمادى الأولى','جمادى الآخرة','رجب','شعبان','رمضان','شوال','ذو القعدة','ذو الحجة'];
    setState(() {
      _currentTime = timeFormat.format(makkahTime);
      _hijriDate = '${today.hDay} ${months[today.hMonth-1]} ${today.hYear} هـ';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('نفحات', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          if (user != null)
            IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              tooltip: 'تسجيل الخروج',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: [colorScheme.primary.withOpacity(0.1), colorScheme.secondary.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0,5))],
              ),
              child: Column(children: [
                Icon(Icons.access_time_rounded, size:40, color: colorScheme.primary),
                const SizedBox(height:12),
                Text(_currentTime, style: TextStyle(fontSize:36, fontWeight:FontWeight.w900, color:colorScheme.primary)),
                const SizedBox(height:4),
                Text('توقيت مكة المكرمة', style: TextStyle(fontSize:12, color: colorScheme.onSurface.withOpacity(0.5))),
                const SizedBox(height:16), Divider(color: colorScheme.primary.withOpacity(0.2)), const SizedBox(height:16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.calendar_month_rounded, size:20, color:colorScheme.primary),
                  const SizedBox(width:8),
                  Text(_hijriDate, style: TextStyle(fontSize:16, fontWeight:FontWeight.w600, color: colorScheme.onSurface.withOpacity(0.8))),
                ]),
              ]),
            ),
            const SizedBox(height:30),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)]), boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius:15, offset:Offset(0,8))]),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder:(_)=>const QuranScreen())),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
                    Container(width:50,height:50,decoration:BoxDecoration(color:Colors.white.withOpacity(0.2),borderRadius:BorderRadius.circular(15)),child:const Icon(Icons.menu_book_rounded,color:Colors.white,size:28)),
                    const SizedBox(width:16),
                    Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [const Text('القرآن الكريم',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:Colors.white)),const SizedBox(height:4),Text('مصحف المدينة النبوية',style:TextStyle(fontSize:13,color:Colors.white.withOpacity(0.8)))])),
                    const Icon(Icons.arrow_forward_ios,color:Colors.white,size:18),
                  ])),
                ),
              ),
            ),
            const SizedBox(height:16),
            Row(children: [
              Expanded(child: _buildBtn(Icons.mosque_rounded, 'مواقيت + بوصلة', ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>const PrayerTimesScreen())))),
              const SizedBox(width:10),
              Expanded(child: _buildBtn(Icons.book_rounded, 'الأحاديث', ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>const HadithScreen())))),
            ]),
            const SizedBox(height:10),
            Row(children: [
              Expanded(child: _buildBtn(Icons.fingerprint, 'المسبحة', ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>const TasbihScreen())))),
              const SizedBox(width:10),
              Expanded(child: _buildBtn(Icons.explore_rounded, 'القبلة', (){})),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(IconData icon, String title, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(borderRadius:BorderRadius.circular(16), border:Border.all(color:colorScheme.primary.withOpacity(0.15)), color:colorScheme.surface.withOpacity(0.8)),
      child: Material(color:Colors.transparent, child: InkWell(onTap:onTap, borderRadius:BorderRadius.circular(16), child: Padding(padding:const EdgeInsets.all(16), child:Column(children:[Icon(icon,color:colorScheme.primary,size:28),const SizedBox(height:8),Text(title,style:TextStyle(fontSize:14,fontWeight:FontWeight.w600,color:colorScheme.onSurface))])))),
    );
  }
}