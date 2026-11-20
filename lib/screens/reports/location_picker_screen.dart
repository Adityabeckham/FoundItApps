import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:foundit/services/reverse_geocoding.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/widgets/top_banner.dart';

/// Hasil pemilihan lokasi dari [LocationPickerScreen].
class SelectedLocation {
  const SelectedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}

/// Peta interaktif untuk memilih lokasi kejadian.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initial});

  final LatLng? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const LatLng _bandung = LatLng(-6.9175, 107.6191);

  final MapController _mapController = MapController();
  late LatLng _selected = widget.initial ?? _bandung;
  bool _locating = false;
  bool _confirming = false;

  Future<void> _goToCurrentLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          TopBanner.error(context, 'Izin lokasi ditolak');
        }
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition();
      final LatLng point = LatLng(pos.latitude, pos.longitude);
      setState(() => _selected = point);
      _mapController.move(point, 17);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    final String? address = await reverseGeocode(
      _selected.latitude,
      _selected.longitude,
    );
    if (!mounted) return;
    setState(() => _confirming = false);
    Navigator.pop(
      context,
      SelectedLocation(
        latitude: _selected.latitude,
        longitude: _selected.longitude,
        address: address ??
            'Lat ${_selected.latitude.toStringAsFixed(5)}, '
                'Lng ${_selected.longitude.toStringAsFixed(5)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgScreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Pilih Lokasi',
          style: AppTextStyles.headingS17.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected,
                    initialZoom: 16,
                    onTap: (TapPosition tapPosition, LatLng point) {
                      setState(() => _selected = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.foundit',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selected,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.error,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: AppSpacing.s12,
                  right: AppSpacing.s12,
                  child: FloatingActionButton.extended(
                    onPressed: _locating ? null : _goToCurrentLocation,
                    backgroundColor: AppColors.bgSurface,
                    foregroundColor: AppColors.primary,
                    icon: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                    label: Text(
                      'Lokasi Saya',
                      style: AppTextStyles.labelM12Semi.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              AppSpacing.s16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lokasi terpilih', style: AppTextStyles.titleM14),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Lat ${_selected.latitude.toStringAsFixed(5)}, '
                    'Lng ${_selected.longitude.toStringAsFixed(5)}',
                    style: AppTextStyles.bodyM13.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Ketuk peta untuk memindahkan titik lokasi.',
                    style: AppTextStyles.bodyS12.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _confirming ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bgInverse,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _confirming
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Gunakan Lokasi Ini',
                              style: AppTextStyles.labelXl15.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
