import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/core.dart';

class LocationPage extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const LocationPage({
    super.key, 
    this.latitude,
    this.longitude,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // Kalau lat/lng belum tersedia -> tampilkan loading
    if (widget.latitude == null || widget.longitude == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final LatLng center = LatLng(widget.latitude!, widget.longitude!);

    final Marker marker = Marker(
      markerId: const MarkerId("marker_1"),
      position: center,
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: center,
              zoom: 18.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {marker},
          ),

          // Back Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 50.0,
            ),
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Assets.icons.back.svg(),
            ),
          ),
        ],
      ),
    );
  }
}
