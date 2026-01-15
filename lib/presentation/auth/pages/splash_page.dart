import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_pages.dart';

import '../../../core/core.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final isAuth = await AuthLocalDataSource().isAuth();
    if (!mounted) return;

    if (isAuth) {
      context.pushReplacement(const MainPage());
    } else {
      context.pushReplacement(const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Navy Prisma
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PRISMA (lebih berkarakter)
            Text(
              'PRISMA',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w600, // tidak terlalu bold
                letterSpacing: 2.2, // ini yang bikin premium
              ),
            ),

            const SizedBox(height: 14),

            // Divider tipis
            Container(
              width: 170,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 14),

            // Subtitle
            Text(
              'Integrated Facility Services',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
