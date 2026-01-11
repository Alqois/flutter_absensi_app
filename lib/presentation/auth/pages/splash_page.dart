import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Assets.images.logoWhite.image(),
          ),
          const Spacer(),
          Assets.images.logoCodeWithBahri.image(height: 70),
          const SpaceHeight(20.0),
        ],
      ),
    );
  }
}
