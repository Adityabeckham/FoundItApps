import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_spacing.dart';

/// Preview peta kecil yang menampilkan satu titik lokasi terpilih.
class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 140,
  });

  final double latitude;
  final double longitude;
  final double height;

  @override
  Widget build(BuildContext context) {
    final LatLng point = LatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.foundit',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.error,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
