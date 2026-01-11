import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PermissionRemoteDatasource {
  Future<Either<String, String>> addPermission({
    required String date,
    required String reason,
    XFile? image,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();

      if (authData == null || authData.token == null) {
        return const Left("Unauthorized: token tidak ditemukan");
      }

      // Sesuai Postman: /api/api-permissions
      final url = Uri.parse('${Variables.baseUrl}/api/api-permissions');

      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      });

      request.fields['date_permission'] = date; // sesuai field di respons Postman
      request.fields['reason'] = reason;

      // Kirim file jika ada
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      http.StreamedResponse response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return const Right("Permission request created successfully");
      } else {
        return Left("Failed: $body");
      }
    } catch (e) {
      return Left("Error: $e");
    }
  }
}
