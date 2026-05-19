import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() { _errorMessage = _getArabicMessage(e.code); });
    } catch (e) {
      setState(() { _errorMessage = 'حدث خطأ غير متوقع'; });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn.standard().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() { _errorMessage = _getArabicMessage(e.code); });
    } catch (e) {
      setState(() { _errorMessage = 'حدث خطأ غير متوقع'; });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _getArabicMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'المستخدم غير موجود';
      case 'wrong-password': return 'كلمة المرور غير صحيحة';
      case 'invalid-email': return 'البريد الإلكتروني غير صالح';
      case 'user-disabled': return 'تم تعطيل هذا الحساب';
      case 'email-already-in-use': return 'البريد الإلكتروني مستخدم مسبقاً';
      case 'weak-password': return 'كلمة المرور ضعيفة جداً';
      case 'invalid-credential': return 'بيانات الدخول غير صحيحة';
      default: return 'حدث خطأ: $code';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)]),
                    boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'مرحباً بعودتك إلى نفحات' : 'أنشئ حسابك للاستفادة من جميع الميزات',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 36),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.red.shade200)),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 14), textAlign: TextAlign.center),
                ),
              if (!_isLogin) ...[
                _buildTextField(controller: _nameController, hint: 'الاسم الكامل', icon: Icons.person_rounded),
                const SizedBox(height: 14),
              ],
              _buildTextField(controller: _emailController, hint: 'البريد الإلكتروني', icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _buildTextField(controller: _passwordController, hint: 'كلمة المرور', icon: Icons.lock_rounded, isPassword: true),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('أو', style: TextStyle(color: Colors.grey.shade500, fontSize: 14))), const Expanded(child: Divider())]),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network('https://www.google.com/favicon.ico', width: 24, height: 24),
                      const SizedBox(width: 12),
                      Text('متابعة باستخدام Google', style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? 'ليس لديك حساب؟ ' : 'لديك حساب بالفعل؟ ', style: TextStyle(color: Colors.grey.shade600)),
                  GestureDetector(
                    onTap: () => setState(() { _isLogin = !_isLogin; _errorMessage = null; }),
                    child: Text(_isLogin ? 'أنشئ حساباً' : 'تسجيل الدخول', style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextField(
        controller: controller, obscureText: isPassword, keyboardType: keyboardType, textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.ibmPlexSansArabic(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: colorScheme.primary), filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
        ),
      ),
    );
  }
}
