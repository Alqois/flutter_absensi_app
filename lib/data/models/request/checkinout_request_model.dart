import 'dart:convert';

class CheckInOutRequestModel {
  final String? latitude;
  final String? longitude;

  // ✅ tambahan
  final bool? checkoutWithoutCheckin;

  CheckInOutRequestModel({
    this.latitude,
    this.longitude,
    this.checkoutWithoutCheckin,
  });

  factory CheckInOutRequestModel.fromJson(String str) =>
      CheckInOutRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CheckInOutRequestModel.fromMap(Map<String, dynamic> json) =>
      CheckInOutRequestModel(
        latitude: json["latitude"],
        longitude: json["longitude"],
        checkoutWithoutCheckin: json["checkout_without_checkin"] == null
            ? null
            : (json["checkout_without_checkin"] is bool
                ? json["checkout_without_checkin"] as bool
                : json["checkout_without_checkin"] == 1),
      );

  Map<String, dynamic> toMap() => {
        "latitude": latitude,
        "longitude": longitude,
        // ✅ hanya dikirim kalau ada
        if (checkoutWithoutCheckin != null)
          "checkout_without_checkin": checkoutWithoutCheckin,
      };
}
