import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/response/user_response_model.dart';

String embeddingToString(List<double> emb) {
  return emb.map((e) => e.toString()).join(",");
}

class AuthRemoteDataSource {
  // -------------------------------
  // LOGIN (WITH FCM TOKEN UPDATE)
  // -------------------------------
  Future<Either<String, AuthResponseModel>> login(
      String username, String password) async {

    final url = Uri.parse('${Variables.baseUrl}/api/login');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': username,
        'password': password,
      }),
    );

    print("📥 LOGIN STATUS = ${response.statusCode}");
    print("📥 LOGIN RESPONSE = ${response.body}");

    if (response.statusCode == 200) {

      // 1. SIMPAN AUTH
      await AuthLocalDataSource().saveAuthData(response.body);

      // 2. AMBIL TOKEN FCM
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print("🔥 FCM TOKEN SETELAH LOGIN = $fcmToken");

      // 3. KIRIM TOKEN KE SERVER
      if (fcmToken != null) {
        await updateUserFcmToken(fcmToken);
      }

      // 4. RETURN
      return Right(AuthResponseModel.fromJson(response.body));
    } 
    else {
      return const Left('Failed to login');
    }
  }

  // -------------------------------
  // LOGOUT
  // -------------------------------
  Future<Either<String, String>> logout() async {
    final auth = await AuthLocalDataSource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/logout');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${auth?.token}',
      },
    );

    if (response.statusCode == 200) {
      return const Right('Logout success');
    } else {
      return const Left('Failed to logout');
    }
  }

  // -------------------------------
  // UPDATE PROFILE (FACE EMBEDDING + IMAGE)
  // -------------------------------
  Future<Either<String, User>> updateProfileRegisterFace(
    List<double> embedding,
    Uint8List imageBytes,
  ) async {
    final auth = await AuthLocalDataSource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/update-profile');

    final embeddingJson = jsonEncode(embedding);

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${auth?.token}'
      ..headers['Accept'] = 'application/json'
      ..fields['face_embedding'] = embeddingJson
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

    final streamedResponse = await request.send();
    final responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final jsonBody = jsonDecode(responseString);
      final userJson = jsonBody['user'];

      return Right(User.fromMap(userJson));
    } else {
      return Left(responseString);
    }
  }

  // -------------------------------
  // UPDATE FCM TOKEN
  // -------------------------------
  Future<void> updateUserFcmToken(String fcmToken) async {
    final auth = await AuthLocalDataSource().getAuthData();

    if (auth == null) {
      print("🔴 AUTH EMPTY – FCM token tidak terkirim.");
      return;
    }

    final url = Uri.parse('${Variables.baseUrl}/api/update-fcm-token');

    print("📡 MENGIRIM FCM TOKEN KE BACKEND: $fcmToken");

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      },
      body: jsonEncode({
        'fcm_token': fcmToken,
      }),
    );

    print("📥 UPDATE TOKEN STATUS = ${response.statusCode}");
    print("📥 UPDATE TOKEN RESPONSE = ${response.body}");
  }

  // -------------------------------
  // FORGOT PASSWORD
  // -------------------------------
  Future<Either<String, String>> forgotPassword(String email) async {
    final url = Uri.parse('${Variables.baseUrl}/api/auth/forgot-password');

    final res = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return Right(body['message']?.toString() ?? 'OTP dikirim.');
    } else {
      try {
        final body = jsonDecode(res.body);
        return Left(body['message']?.toString() ?? 'Gagal mengirim OTP');
      } catch (_) {
        return const Left('Gagal mengirim OTP');
      }
    }
  }

  // -------------------------------
  // RESET PASSWORD (OTP)
  // -------------------------------
  Future<Either<String, String>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('${Variables.baseUrl}/api/auth/reset-password');

    final res = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return Right(body['message']?.toString() ?? 'Password berhasil direset.');
    } else {
      try {
        final body = jsonDecode(res.body);
        return Left(body['message']?.toString() ?? 'Gagal reset password');
      } catch (_) {
        return const Left('Gagal reset password');
      }
    }
  }

  // -------------------------------
  // CHANGE PASSWORD (NEED LOGIN/TOKEN)
  // -------------------------------
  Future<Either<String, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final auth = await AuthLocalDataSource().getAuthData();
    if (auth == null) return const Left('Auth kosong. Silakan login ulang.');

    final url = Uri.parse('${Variables.baseUrl}/api/auth/change-password');

    final res = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      }),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return Right(body['message']?.toString() ?? 'Password berhasil diganti.');
    } else {
      try {
        final body = jsonDecode(res.body);
        return Left(body['message']?.toString() ?? 'Gagal ganti password');
      } catch (_) {
        return const Left('Gagal ganti password');
      }
    }
  }


}
