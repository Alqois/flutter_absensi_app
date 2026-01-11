import 'package:location/location.dart';

class FakeLocationService {
  static Future<bool> isFakeLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    PermissionStatus perm = await location.hasPermission();
    if (perm == PermissionStatus.denied) {
      perm = await location.requestPermission();
    }

    LocationData data = await location.getLocation();

    /// 1. Cek apakah isMock = true
    if (data.isMock ?? false) {
      print("FAKE GPS: FLAG isMock TRUE");
      return true;
    }

    /// 2. Akurasi tidak realistis (<5 meter)
    if ((data.accuracy ?? 50) < 5) {
      print("FAKE GPS: Akurasi terlalu rendah");
      return true;
    }

    /// 3. Cek provider
    if ((data.provider ?? "").contains("fused")) {
      print("FAKE GPS: Provider mencurigakan (fused)");
      // tidak langsung true, tapi warning
    }

    return false;
  }
}
