import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:flutter_absensi_app/presentation/auth/pages/login_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool notificationEnabled = true;

  Future<void> _forceLogout() async {
    // ✅ hapus auth lokal dulu (pasti berhasil logout dari sisi app)
    await AuthLocalDataSource().removeAuthData();

    if (!mounted) return;

    // ✅ reset navigation stack biar gak bisa back ke home
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),

      // BlocConsumer masih boleh dipakai buat tampilkan error API logout kalau mau
      body: BlocListener<LogoutBloc, LogoutState>(
        listener: (context, state) {
          state.maybeMap(
            error: (value) {
              // kalau API logout error, kita cuma kasih info, tapi user tetap sudah keluar karena force logout
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value.error),
                  backgroundColor: AppColors.red,
                ),
              );
            },
            orElse: () {},
          );
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Account'),
            _settingCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Profile'),
                    subtitle: const Text('Lihat & ubah data akun'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(const ProfilePage()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionTitle('Preferences'),
            _settingCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: notificationEnabled,
                    onChanged: (value) => setState(() {
                      notificationEnabled = value;
                    }),
                    secondary: const Icon(Icons.notifications_none),
                    title: const Text('Notifikasi'),
                    subtitle: const Text('Aktifkan notifikasi aplikasi'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionTitle('About'),
            _settingCard(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Tentang Aplikasi'),
                    subtitle: Text('Prisma Absensi v1.0.0'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ✅ LOGOUT (FORCE)
            _settingCard(
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  // (opsional) coba hit server logout, tapi jangan nunggu hasilnya
                  context.read<LogoutBloc>().add(const LogoutEvent.logout());

                  // ✅ langsung keluar dari app
                  await _forceLogout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _settingCard({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: child,
    );
  }
}
