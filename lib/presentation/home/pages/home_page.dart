import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_absensi_app/core/helper/radius_calculate.dart';
import 'package:flutter_absensi_app/core/services/fake_location_service.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_checkin_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_checkout_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/permission_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/register_face_attendance_page.dart';
import 'package:flutter_absensi_app/presentation/home/widget/menu_button.dart';
import 'package:flutter_absensi_app/presentation/home/pages/setting_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import '../../../core/core.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? faceEmbedding;

  @override
  void initState() {
    _initializeFaceEmbedding();
    getCurrentPosition();
    context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.IsCheckedIn());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());
    super.initState();
  }

  double? latitude;
  double? longitude;

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

      setState(() {});
    } catch (e) {}
  }

  Future<void> _initializeFaceEmbedding() async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      setState(() {
        faceEmbedding = authData?.user?.faceEmbedding;
      });
    } catch (e) {
      faceEmbedding = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.bgHome.provider(),
              alignment: Alignment.topCenter,
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // =======================
              // HEADER
              // =======================
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image.network(
                      'https://i.pinimg.com/originals/1b/14/53/1b14536a5f7e70664550df4ccaa5b231.jpg',
                      width: 48.0,
                      height: 48.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SpaceWidth(12.0),
                  Expanded(
                    child: FutureBuilder(
                      future: AuthLocalDataSource().getAuthData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        }
                        final user = snapshot.data?.user;
                        return Text(
                          'Hello, ${user?.name ?? 'Hello, User'}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: AppColors.white,
                          ),
                          maxLines: 2,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Assets.icons.notificationRounded.svg(),
                  ),
                ],
              ),

              const SpaceHeight(24.0),

              // =======================
              // JAM KERJA CARD
              // =======================
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    Text(
                      DateTime.now().toFormattedTime(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      DateTime.now().toFormattedDate(),
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                    const SpaceHeight(18.0),
                    const Divider(),
                    const SpaceHeight(30.0),
                    Text(
                      DateTime.now().toFormattedDate(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                    const SpaceHeight(6.0),
                    Text(
                      '${DateTime(2024, 3, 14, 8, 0).toFormattedTime()} - '
                      '${DateTime(2024, 3, 14, 16, 0).toFormattedTime()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SpaceHeight(80.0),

              // =======================
              // MENU GRID
              // =======================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  children: [
                    // =======================
                    // CHECK-IN
                    // =======================
                    BlocBuilder<GetCompanyBloc, GetCompanyState>(
                      builder: (context, state) {
                        final latitudePoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.latitude!),
                        );
                        final longitudePoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.longitude!),
                        );
                        final radiusPoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.radiusKm!),
                        );

                        return BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
                          builder: (context, state) {
                            final isCheckin = state.maybeWhen(
                              success: (data) => data.IsCheckedin,
                              orElse: () => false,
                            );

                            final isCheckout = state.maybeWhen(
                              success: (data) => data.IsCheckedout,
                              orElse: () => false,
                            );

                            return MenuButton(
                              label: 'Datang',
                              iconPath: Assets.icons.menu.datang.path,
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
                            );
                          },
                        );
                      },
                    ),

                    // =======================
                    // CHECK-OUT
                    // =======================
                    BlocBuilder<GetCompanyBloc, GetCompanyState>(
                      builder: (context, state) {
                        final latitudePoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.latitude!),
                        );
                        final longitudePoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.longitude!),
                        );
                        final radiusPoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.radiusKm!),
                        );

                        return BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
                          builder: (context, state) {
                            final isCheckin = state.maybeWhen(
                              success: (data) => data.IsCheckedin,
                              orElse: () => false,
                            );

                            final isCheckout = state.maybeWhen(
                              success: (data) => data.IsCheckedout,
                              orElse: () => false,
                            );

                            return MenuButton(
                              label: 'Pulang',
                              iconPath: Assets.icons.menu.pulang.path,
                              onPressed: () async {
                                if (await FakeLocationService.isFakeLocation()) {
                                  _fakeGPSDialog();
                                  return;
                                }

                                if (!isCheckin) {
                                  _snack('Anda harus check-in dulu');
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
                                  _snack('Anda di luar radius checkout');
                                  return;
                                }

                                context.push(const AttendanceCheckoutPage());
                              },
                            );
                          },
                        );
                      },
                    ),

                    MenuButton(
                      label: 'Izin',
                      iconPath: Assets.icons.menu.izin.path,
                      onPressed: () {
                        context.push(const PermissionPage());
                      },
                    ),

                    MenuButton(
                      label: 'Catatan',
                      iconPath: Assets.icons.menu.catatan.path,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SpaceHeight(24.0),

              // =======================
              // FACE ID BUTTON (FINAL)
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

                  // MODE 1 → Belum Registrasi
                  if (faceEmbedding == null) {
                    return Button.filled(
                      label: 'Register Face ID',
                      icon: Assets.icons.attendance.svg(),
                      color: AppColors.red,
                      onPressed: () {
                        context.push(const RegisterFaceAttendencePage());
                      },
                    );
                  }

                  // MODE 2 & 3 → Sudah Registrasi
                  return BlocBuilder<GetCompanyBloc, GetCompanyState>(
                    builder: (context, companyState) {
                      final latitudePoint = companyState.maybeWhen(
                        orElse: () => 0.0,
                        success: (d) => double.parse(d.latitude!),
                      );

                      final longitudePoint = companyState.maybeWhen(
                        orElse: () => 0.0,
                        success: (d) => double.parse(d.longitude!),
                      );

                      final radiusPoint = companyState.maybeWhen(
                        orElse: () => 0.0,
                        success: (d) => double.parse(d.radiusKm!),
                      );

                      return Button.filled(
                        label: isCheckin && !isCheckout
                            ? "Checkout Using Face ID"
                            : "Check-in Using Face ID",
                        icon: Assets.icons.attendance.svg(),
                        color: AppColors.primary,
                        onPressed: () {
                          final distanceKM = RadiusCalculate.calculateDistance(
                            latitude ?? 0.0,
                            longitude ?? 0.0,
                            latitudePoint,
                            longitudePoint,
                          );

                          if (distanceKM > radiusPoint) {
                            _snack('Anda di luar radius Face ID');
                            return;
                          }

                          // Check-in Face ID
                          if (!isCheckin) {
                            context.push(const AttendanceCheckinPage());
                            return;
                          }

                          // Checkout Face ID
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

            ],
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
