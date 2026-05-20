import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.menu_book_rounded,
      'title': 'اقرأ القرآن الكريم',
      'desc': 'مصحف المدينة المنورة برواية حفص\nخط عثماني واضح ومريح للقراءة تالياً ومتدبراً.',
      'color': const Color(0xFF0B3C18),
    },
    {
      'icon': Icons.headphones_rounded,
      'title': 'استمع للتلاوات العذبة',
      'desc': 'مجموعة مختارة من أصوات كبار القراء في العالم الإسلامي بجودة صوتية نقية.',
      'color': const Color(0xFFC5A880),
    },
    {
      'icon': Icons.track_changes_rounded,
      'title': 'حافظ على أورادك',
      'desc': 'تابع تقدمك الإيماني اليومي واجعل ذكر الله رفيق يومك في كل حركتك.',
      'color': const Color(0xFF1B5E20),
    },
    {
      'icon': Icons.mosque_rounded,
      'title': 'مواقيت دقيقة والقبلة',
      'desc': 'تنبيهات دقيقة لكل الصلوات مع بوصلة متطورة لتحديد اتجاه القبلة أينما كنت.',
      'color': const Color(0xFF004D40),
    },
  ];

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == i
                            ? _pages[i]['color']
                            : (isDark ? Colors.white24 : Colors.black12),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _goToHome,
                        child: Text(
                          'تخطي',
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.fastOutSlowIn,
                          );
                        } else {
                          _goToHome();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage]['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage < _pages.length - 1 ? 'التالي' : 'ابدأ الآن',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    final color = page['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.0),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Icon(page['icon'], size: 64, color: color),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page['title'],
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page['desc'],
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
