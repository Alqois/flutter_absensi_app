import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/user_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String key = 'auth_data';

  /// SIMPAN RAW JSON dari API login
  /// contoh: response.body
  Future<void> saveAuthData(String rawJson) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(key, rawJson);
  }

  /// AMBIL DATA LOGIN dari local storage
  Future<AuthResponseModel?> getAuthData() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString(key);

    if (data == null) return null;

    // decode raw JSON asli dari backend
    return AuthResponseModel.fromJson(data);
  }

  /// HAPUS DATA AUTH (dipakai saat logout)
  Future<void> removeAuthData() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }

  /// CEK APAKAH USER SUDAH LOGIN
  Future<bool> isAuth() async {
    final pref = await SharedPreferences.getInstance();
    return pref.containsKey(key);
  }

  /// UPDATE DATA USER (setelah update profile, update face, dsb.)
  Future<void> updateAuthData(User user) async {
    final pref = await SharedPreferences.getInstance();
    final authData = await getAuthData();

    if (authData != null) {
      final updated = authData.copyWith(user: user);

      // penting! simpan kembali sebagai JSON asli, bukan Map!
      await pref.setString(key, updated.toJson());
    }
  }

  /// UPDATE FACE EMBEDDING SAJA (dipakai saat register wajah)
  Future<void> updateFaceEmbedding(List<double> embedding) async {
    final pref = await SharedPreferences.getInstance();
    final authData = await getAuthData();

    if (authData != null) {
      final embeddingString = embedding.toString();

      final updatedUser = authData.user.copyWith(
        faceEmbedding: embeddingString,
      );

      final updatedAuth = authData.copyWith(user: updatedUser);

      await pref.setString(key, updatedAuth.toJson());
    }
  }
}
