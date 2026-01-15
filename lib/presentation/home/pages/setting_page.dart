import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:flutter_absensi_app/presentation/auth/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool notificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: BlocConsumer<LogoutBloc, LogoutState>(
        listener: (context, state) {
          state.maybeMap(
            orElse: () {},
            success: (_) {
              context.pushReplacement(const LoginPage());
            },
            error: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value.error),
                  backgroundColor: AppColors.red,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            orElse: () {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// ===== ACCOUNT =====
                  _sectionTitle('Account'),
                  _settingCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Profile'),
                          subtitle: const Text('Lihat & ubah data akun'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: ke halaman profile
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ===== PREFERENCES =====
                  _sectionTitle('Preferences'),
                  _settingCard(
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: notificationEnabled,
                          onChanged: (value) {
                            setState(() {
                              notificationEnabled = value;
                            });
                          },
                          secondary: const Icon(Icons.notifications_none),
                          title: const Text('Notifikasi'),
                          subtitle: const Text('Aktifkan notifikasi aplikasi'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ===== ABOUT =====
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

                  /// ===== LOGOUT =====
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
                      onTap: () {
                        context
                            .read<LogoutBloc>()
                            .add(const LogoutEvent.logout());
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// ===== HELPER =====

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
