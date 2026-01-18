import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/firebase_messanging_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/permission_remote_datasource.dart';
import 'package:flutter_absensi_app/firebase_options.dart';
import 'package:flutter_absensi_app/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/add_permission/add_permission_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkin_attendance/checkin_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkout_attendance/checkout_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_attendance_by_date/get_attendance_by_date_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/update_user_register_face/update_user_register_face_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/core.dart';
import 'core/helper/notification_storage.dart';
import 'presentation/auth/bloc/login/login_bloc.dart';
import 'presentation/auth/pages/splash_page.dart';

/// ✅ GLOBAL navigatorKey (dipakai untuk paksa balik login dari bloc)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final title = message.notification?.title ?? 'Notifikasi';
  final body = message.notification?.body ?? '';

  // Best-effort simpan (kalau handler kepanggil)
  await NotificationStorage.push(
    title: title,
    message: body,
    type: message.data['type'] ?? 'general',
  );

  // ignore: avoid_print
  print("🔔 BG MESSAGE: $title");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Pasang background handler di sini saja
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Semua listener foreground/tap/initial pindah ke datasource (biar satu pintu)
  await FirebaseMessagingRemoteDatasource().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc(AuthRemoteDataSource())),
        BlocProvider(create: (_) => LogoutBloc(AuthRemoteDataSource())),
        BlocProvider(create: (_) => UpdateUserRegisterFaceBloc(AuthRemoteDataSource())),
        BlocProvider(create: (_) => GetCompanyBloc(AttendanceRemoteDatasource())),
        BlocProvider(create: (_) => IsCheckedinBloc(AttendanceRemoteDatasource())),
        BlocProvider(create: (_) => CheckinAttendanceBloc(AttendanceRemoteDatasource())),
        BlocProvider(create: (_) => CheckoutAttendanceBloc(AttendanceRemoteDatasource())),
        BlocProvider(create: (_) => AddPermissionBloc(PermissionRemoteDatasource())),
        BlocProvider(create: (_) => GetAttendanceByDateBloc(AttendanceRemoteDatasource())),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Prisma Absensi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          dividerTheme: DividerThemeData(color: AppColors.light.withOpacity(0.5)),
          dialogTheme: const DialogThemeData(elevation: 0),
          textTheme: GoogleFonts.kumbhSansTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            color: AppColors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.kumbhSans(
              color: AppColors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
