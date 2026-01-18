import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/company_response_model.dart';
import 'package:flutter_absensi_app/main.dart';
import 'package:flutter_absensi_app/presentation/auth/pages/login_page.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_company_event.dart';
part 'get_company_state.dart';
part 'get_company_bloc.freezed.dart';

class GetCompanyBloc extends Bloc<GetCompanyEvent, GetCompanyState> {
  final AttendanceRemoteDatasource datasource;

  GetCompanyBloc(this.datasource) : super(const _Initial()) {
    on<_GetCompany>((event, emit) async {
      emit(const _Loading());

      final result = await datasource.getCompanyProfile();

      result.fold(
        (l) async {
          // ✅ DETEKSI token expired / unauthorized
          // sesuaikan kondisi ini dengan pesan error yang kamu dapet dari datasource
          final msg = l.toString().toLowerCase();
          final isUnauthorized = msg.contains('401') ||
              msg.contains('unauthorized') ||
              msg.contains('unauthenticated') ||
              msg.contains('token') && msg.contains('expired');

          if (isUnauthorized) {
            await AuthLocalDataSource().removeAuthData();

            // ✅ paksa balik login (tanpa butuh context)
            final nav = navigatorKey.currentState;
            if (nav != null) {
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            }

            emit(const _Error('Sesi habis. Silakan login lagi.'));
            return;
          }

          emit(_Error(l));
        },
        (r) {
          // ✅ amanin kalau company null
          final company = r.company;
          if (company == null) {
            emit(const _Error('Data company kosong dari server.'));
            return;
          }

          emit(_Success(company));
        },
      );
    });
  }
}
