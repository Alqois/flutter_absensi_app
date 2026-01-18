import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/core/helper/radius_calculate.dart';
import 'package:flutter_absensi_app/core/services/fake_location_service.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_checkin_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_checkout_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/notification_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/permission_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/profile_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/register_face_attendance_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/setting_page.dart';
import 'package:flutter_absensi_app/presentation/home/widget/menu_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/core.dart';
import '../../../core/helper/notification_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? faceEmbedding;
  double? latitude;
  double? longitude;

  Timer? _clock;

  static const String _photoKey = 'profile_photo_path';

  @override
  void initState() {
    super.initState();
    _initializeFaceEmbedding();
    getCurrentPosition();
    _refreshHome();

    // ✅ jam realtime
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _refreshHome() {
    context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.IsCheckedIn());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());
  }

  Future<String?> _getLocalPhotoPath() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_photoKey);
  }

  Future<void> getCurrentPosition() async {
    try {
      final location = Location();

      bool enabled = await location.serviceEnabled();
      if (!enabled) enabled = await location.requestService();

      PermissionStatus perm = await location.hasPermission();
      if (perm == PermissionStatus.denied) {
        perm = await location.requestPermission();
      }

      final data = await location.getLocation();
      latitude = data.latitude;
      longitude = data.longitude;

      if (mounted) setState(() {});
    } catch (e) {
      // ignore
    }
  }

  Future<void> _initializeFaceEmbedding() async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      if (!mounted) return;
      setState(() {
        faceEmbedding = authData?.user?.faceEmbedding;
      });
    } catch (e) {
      faceEmbedding = null;
    }
  }

  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return '--:--';
    return t.length >= 5 ? t.substring(0, 5) : t;
  }

  Widget _faceIdButton({
    required String label,
    required VoidCallback onPressed,
    bool danger = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: danger
                ? [AppColors.red, AppColors.red.withOpacity(0.85)]
                : [AppColors.primary, AppColors.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.white.withOpacity(0.18)),
              ),
              child: const Icon(Icons.face_rounded, color: AppColors.white),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSheet,
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshHome();
          await Future.delayed(const Duration(milliseconds: 350));
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.primary],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -140,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: -120,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =======================
                        // HEADER
                        // =======================
                        Row(
                          children: [
                            // FOTO PROFILE LOKAL (tap => profile)
                            FutureBuilder<String?>(
                              future: _getLocalPhotoPath(),
                              builder: (context, snapPhoto) {
                                final path = snapPhoto.data;
                                final exists =
                                    path != null && File(path).existsSync();

                                return InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () async {
                                    await context.push(const ProfilePage());
                                    if (!mounted) return;
                                    setState(() {});
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      color:
                                          AppColors.blueLight.withOpacity(0.30),
                                      child: exists
                                          ? Image.file(
                                              File(path!),
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              color: AppColors.white,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SpaceWidth(12),

                            // NAMA USER
                            Expanded(
                              child: FutureBuilder(
                                future: AuthLocalDataSource().getAuthData(),
                                builder: (context, snapshot) {
                                  final user = snapshot.data?.user;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Selamat datang,',
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        user?.name ?? 'User',
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            IconButton(
                              onPressed: _refreshHome,
                              icon: const Icon(Icons.refresh_rounded,
                                  color: AppColors.white),
                            ),

                            // NOTIF + RED DOT (unread)
                            FutureBuilder<int>(
                              future: NotificationStorage.unreadCount(),
                              builder: (context, snap) {
                                final unread = snap.data ?? 0;

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await context
                                            .push(const NotificationPage());
                                        if (!mounted) return;
                                        setState(() {}); // refresh dot
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/icons/notification_prisma.svg',
                                        width: 22,
                                        height: 22,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    if (unread > 0)
                                      Positioned(
                                        top: 8,
                                        right: 10,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),

                            // SETTINGS
                            IconButton(
                              onPressed: () async {
                                await context.push(const SettingPage());
                                if (!mounted) return;
                                setState(() {});
                                _initializeFaceEmbedding();
                              },
                              icon: SvgPicture.asset(
                                'assets/icons/setting_prisma.svg',
                                width: 22,
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SpaceHeight(18),

                        // =======================
                        // STATUS CARD
                        // =======================
                        Container(
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(22.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
                            builder: (context, state) {
                              final isLoading = state.maybeWhen(
                                loading: () => true,
                                orElse: () => false,
                              );

                              final isCheckin = state.maybeWhen(
                                success: (d) => d.IsCheckedin,
                                orElse: () => false,
                              );

                              final isCheckout = state.maybeWhen(
                                success: (d) => d.IsCheckedout,
                                orElse: () => false,
                              );

                              final attendanceTimeIn = state.maybeWhen(
                                success: (d) => d.attendanceTimeIn,
                                orElse: () => null,
                              );

                              final attendanceTimeOut = state.maybeWhen(
                                success: (d) => d.attendanceTimeOut,
                                orElse: () => null,
                              );

                              String statusText;
                              IconData statusIcon;

                              if (isLoading) {
                                statusText = 'Memuat status...';
                                statusIcon = Icons.hourglass_bottom_rounded;
                              } else if (!isCheckin && !isCheckout) {
                                statusText = 'Belum absen hari ini';
                                statusIcon = Icons.info_outline_rounded;
                              } else if (isCheckin && !isCheckout) {
                                statusText =
                                    'Sudah Check-in (${_fmtTime(attendanceTimeIn)})';
                                statusIcon = Icons.login_rounded;
                              } else {
                                statusText =
                                    'Sudah Checkout (${_fmtTime(attendanceTimeOut)})';
                                statusIcon = Icons.logout_rounded;
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      DateTime.now().toFormattedTime(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 34.0,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      DateTime.now().toFormattedDate(),
                                      style: const TextStyle(
                                        color: AppColors.subtitle,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SpaceHeight(16),
                                  const Divider(height: 1),
                                  const SpaceHeight(14),
                                  const Text(
                                    'Jam Kerja',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.subtitle,
                                    ),
                                  ),
                                  const SpaceHeight(8),

                                  // ✅ Jam kerja dari GetCompanyBloc
                                  BlocBuilder<GetCompanyBloc, GetCompanyState>(
                                    builder: (context, cState) {
                                      final timeIn = cState.maybeWhen(
                                        success: (c) => c.timeIn,
                                        orElse: () => null,
                                      );
                                      final timeOut = cState.maybeWhen(
                                        success: (c) => c.timeOut,
                                        orElse: () => null,
                                      );

                                      final companyLoading = cState.maybeWhen(
                                        loading: () => true,
                                        orElse: () => false,
                                      );

                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${_fmtTime(timeIn)} - ${_fmtTime(timeOut)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 20.0,
                                                color: AppColors.title,
                                              ),
                                            ),
                                          ),
                                          if (companyLoading)
                                            const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SpaceHeight(14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 11,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.blueLight,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(statusIcon,
                                            color: AppColors.primary),
                                        const SpaceWidth(10),
                                        Expanded(
                                          child: Text(
                                            statusText,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCheckin) ...[
                                    const SpaceHeight(10.0),
                                    Text(
                                      'Masuk: ${_fmtTime(attendanceTimeIn)}'
                                      '${isCheckout ? ' • Pulang: ${_fmtTime(attendanceTimeOut)}' : ''}',
                                      style: const TextStyle(
                                        color: AppColors.subtitle,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),

                        const SpaceHeight(18),

                        // =======================
                        // QUICK ACTIONS
                        // =======================
                        const Text(
                          'Aksi Cepat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                        const SpaceHeight(12),

                        BlocBuilder<GetCompanyBloc, GetCompanyState>(
                          builder: (context, companyState) {
                            return companyState.maybeWhen(
                              loading: () => Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.94),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (msg) => Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.94),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Gagal memuat data kantor\n$msg",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _refreshHome,
                                      child: const Text("Coba Lagi"),
                                    ),
                                  ],
                                ),
                              ),
                              success: (data) {
                                final latitudePoint =
                                    double.tryParse(data.latitude ?? '') ?? 0.0;
                                final longitudePoint =
                                    double.tryParse(data.longitude ?? '') ?? 0.0;
                                final radiusPoint =
                                    double.tryParse(data.radiusKm ?? '') ?? 0.0;

                                if (latitudePoint == 0 ||
                                    longitudePoint == 0 ||
                                    radiusPoint == 0) {
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.94),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Data lokasi kantor belum lengkap.\nHubungi admin.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: _refreshHome,
                                          child: const Text("Refresh"),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
                                  builder: (context, state) {
                                    final isCheckin = state.maybeWhen(
                                      success: (d) => d.IsCheckedin,
                                      orElse: () => false,
                                    );
                                    final isCheckout = state.maybeWhen(
                                      success: (d) => d.IsCheckedout,
                                      orElse: () => false,
                                    );

                                    return Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.white.withOpacity(0.94),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: Column(
                                        children: [
                                          MenuButton(
                                            label: 'Datang (Check-in)',
                                            iconPath:
                                                'assets/icons/menu/datang_prisma.svg',
                                            disabled: isCheckin || isCheckout,
                                            onPressed: () async {
                                              if (await FakeLocationService.isFakeLocation()) {
                                                _fakeGPSDialog();
                                                return;
                                              }
                                              if (isCheckin) {
                                                _snack('Anda sudah check-in');
                                                return;
                                              }
                                              if (isCheckout) {
                                                _snack('Anda sudah checkout hari ini');
                                                return;
                                              }

                                              final distanceKM = RadiusCalculate.calculateDistance(
                                                latitude ?? 0.0,
                                                longitude ?? 0.0,
                                                latitudePoint,
                                                longitudePoint,
                                              );

                                              if (distanceKM > radiusPoint) {
                                                _snack('Anda di luar jangkauan check-in');
                                                return;
                                              }

                                              context.push(const AttendanceCheckinPage());
                                            },
                                          ),
                                          const SpaceHeight(12),
                                          MenuButton(
                                            label: 'Pulang (Checkout)',
                                            iconPath: 'assets/icons/menu/pulang_prisma.svg',
                                            disabled: isCheckout, // ✅ cuma disable kalau sudah checkout
                                            onPressed: () async {
                                              if (await FakeLocationService.isFakeLocation()) {
                                                _fakeGPSDialog();
                                                return;
                                              }

                                              if (isCheckout) {
                                                _snack('Anda sudah checkout hari ini');
                                                return;
                                              }

                                              // optional info (tidak ngeblok)
                                              if (!isCheckin) {
                                                _snack('Anda belum check-in, checkout akan tercatat tanpa check-in');
                                              }

                                              final distanceKM = RadiusCalculate.calculateDistance(
                                                latitude ?? 0.0,
                                                longitude ?? 0.0,
                                                latitudePoint,
                                                longitudePoint,
                                              );

                                              if (distanceKM > radiusPoint) {
                                                _snack('Anda di luar radius checkout');
                                                return;
                                              }

                                              context.push(const AttendanceCheckoutPage());
                                            },
                                          ),
                                          const SpaceHeight(12),
                                          MenuButton(
                                            label: 'Izin / Permission',
                                            iconPath:
                                                'assets/icons/menu/izin_prisma.svg',
                                            onPressed: () =>
                                                context.push(const PermissionPage()),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              orElse: () => const SizedBox.shrink(),
                            );
                          },
                        ),

                        const SpaceHeight(14),

                        // =======================
                        // FACE ID BUTTON
                        // =======================
                        BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
                          builder: (context, checkState) {
                            final isCheckin = checkState.maybeWhen(
                              success: (d) => d.IsCheckedin,
                              orElse: () => false,
                            );

                            final isCheckout = checkState.maybeWhen(
                              success: (d) => d.IsCheckedout,
                              orElse: () => false,
                            );

                            if (faceEmbedding == null) {
                              return _faceIdButton(
                                label: 'Register Face ID',
                                danger: true,
                                onPressed: () => context.push(
                                  const RegisterFaceAttendencePage(),
                                ),
                              );
                            }

                            return BlocBuilder<GetCompanyBloc, GetCompanyState>(
                              builder: (context, companyState) {
                                final latitudePoint = companyState.maybeWhen(
                                  success: (d) =>
                                      double.tryParse(d.latitude ?? '') ?? 0.0,
                                  orElse: () => 0.0,
                                );

                                final longitudePoint = companyState.maybeWhen(
                                  success: (d) =>
                                      double.tryParse(d.longitude ?? '') ?? 0.0,
                                  orElse: () => 0.0,
                                );

                                final radiusPoint = companyState.maybeWhen(
                                  success: (d) =>
                                      double.tryParse(d.radiusKm ?? '') ?? 0.0,
                                  orElse: () => 0.0,
                                );

                                return _faceIdButton(
                                  label: isCheckin && !isCheckout
                                      ? "Checkout Using Face ID"
                                      : "Check-in Using Face ID",
                                  onPressed: () async {
                                    if (await FakeLocationService.isFakeLocation()) {
                                      _fakeGPSDialog();
                                      return;
                                    }

                                    final distanceKM =
                                        RadiusCalculate.calculateDistance(
                                      latitude ?? 0.0,
                                      longitude ?? 0.0,
                                      latitudePoint,
                                      longitudePoint,
                                    );

                                    if (distanceKM > radiusPoint) {
                                      _snack('Anda di luar radius Face ID');
                                      return;
                                    }

                                    if (!isCheckin) {
                                      context.push(const AttendanceCheckinPage());
                                      return;
                                    }

                                    if (isCheckin && !isCheckout) {
                                      context.push(const AttendanceCheckoutPage());
                                      return;
                                    }

                                    _snack('Anda sudah checkout hari ini');
                                  },
                                );
                              },
                            );
                          },
                        ),

                        const SpaceHeight(28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.red,
      ),
    );
  }

  void _fakeGPSDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Fake GPS Terdeteksi"),
        content: const Text("Matikan aplikasi lokasi palsu terlebih dahulu."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
