import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/request/checkinout_request_model.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/checkinout_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/company_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_absensi_app/presentation/home/models/absent_status.dart';

class AttendanceRemoteDatasource {

  Future<Either<String, CompanyResponseModel>> getCompanyProfile() async {
    final authData = await AuthLocalDataSource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/company');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      final companyResponse = CompanyResponseModel.fromJson(response.body);
      return Right(companyResponse);
    } else {
      return const Left('Failed to fetch company profile');
    }
  }

  Future<Either<String, AbsentStatus>> IsCheckedin() async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final url = Uri.parse('${Variables.baseUrl}/api/is-checkin');
  
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authData?.token}',
        },
      );
  
      if (response.statusCode == 200) {
        final r = jsonDecode(response.body);
        final attendance = r["attendance"]; // bisa null
  
        return Right(
          AbsentStatus(
            IsCheckedin: r["checkedin"] as bool,
            IsCheckedout: r["checkedout"] as bool,
            companyTimeIn: r["time_in"] as String?,
            companyTimeOut: r["time_out"] as String?,
            attendanceTimeIn: attendance?["time_in"] as String?,
            attendanceTimeOut: attendance?["time_out"] as String?,
          ),
        );
      }
  
      // ✅ wajib ada return untuk kasus selain 200
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Failed to check attendance status';
      return Left(message);
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<String, CheckInOutResponseModel>> checkin(
  CheckInOutRequestModel data,
  ) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final url = Uri.parse('${Variables.baseUrl}/api/checkin');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authData?.token}',
        },
        body: data.toJson(),
      );

      if (response.statusCode == 200) {
        return Right(CheckInOutResponseModel.fromJson(response.body));
      } else {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Failed to check in';
        return Left(message);
      }
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<String, CheckInOutResponseModel>> checkout(
  CheckInOutRequestModel data,
  ) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final url = Uri.parse('${Variables.baseUrl}/api/checkout');
  
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authData?.token}',
        },
        body: data.toJson(),
      );
  
      if (response.statusCode == 200) {
        return Right(CheckInOutResponseModel.fromJson(response.body));
      } else {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Failed to checkout';
        return Left(message);
      }
    } catch (e) {
      return Left('Exception: $e');
    }
  }


  Future<Either<String, AttendanceResponseModel>> getAttendance(
      String date) async {
    final authData = await AuthLocalDataSource().getAuthData();
    final url =
        Uri.parse('${Variables.baseUrl}/api/api-attendances?date=$date');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      return Right(AttendanceResponseModel.fromJson(response.body));
    } else {
      return const Left('Failed to get attendance');
    }
  }
}
