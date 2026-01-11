import 'dart:convert';
import 'user_response_model.dart';

class AuthResponseModel {
  final String token;
  final User user;

  AuthResponseModel({
    required this.token,
    required this.user,
  });

  // ---------- COPYWITH ----------
  AuthResponseModel copyWith({
    String? token,
    User? user,
  }) {
    return AuthResponseModel(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }

  // ---------- FROM JSON ----------
  factory AuthResponseModel.fromJson(String str) =>
      AuthResponseModel.fromMap(json.decode(str));

  factory AuthResponseModel.fromMap(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json["token"] ?? "",
      user: User.fromMap(json["user"]),
    );
  }

  // ---------- TO JSON ----------
  Map<String, dynamic> toMap() => {
        "token": token,
        "user": user.toMap(),
      };

  String toJson() => json.encode(toMap());
}
