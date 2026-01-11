import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? position;
  final String? departement;
  final String? faceEmbedding;
  final String? imageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.position,
    this.departement,
    this.faceEmbedding,
    this.imageUrl,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? position,
    String? departement,
    String? faceEmbedding,
    String? imageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      position: position ?? this.position,
      departement: departement ?? this.departement,
      faceEmbedding: faceEmbedding ?? this.faceEmbedding,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"],
        role: json["role"],
        position: json["position"],
        departement: json["departement"],
        faceEmbedding: json["face_embedding"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "position": position,
        "departement": departement,
        "face_embedding": faceEmbedding,
        "image_url": imageUrl,
      };

  String toJson() => json.encode(toMap());
}
