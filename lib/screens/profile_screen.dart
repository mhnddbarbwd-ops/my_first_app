import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? Center(
              child: Text(
                'لم يتم تسجيل الدخول',
                style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.onSurface),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // صورة المستخدم
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.displayName ?? user.email ?? '?')[0].toUpperCase(),
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),
                  // اسم المستخدم
                  Text(
                    user.displayName ?? 'مستخدم نفحات',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // البريد الإلكتروني
                  Text(
                    user.email ?? '',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // بطاقة المعلومات
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.1),
                          colorScheme.secondary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.verified_user, 'تم التحقق', user.emailVerified ? 'نعم' : 'لا', colorScheme),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.calendar_today, 'تاريخ التسجيل', _formatDate(user.metadata.creationTime), colorScheme),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.login, 'آخر تسجيل دخول', _formatDate(user.metadata.lastSignInTime), colorScheme),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // زر تسجيل الخروج
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: Text(
                        'تسجيل الخروج',
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير متوفر';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}