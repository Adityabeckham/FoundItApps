import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:foundit/models/item_report.dart';
import 'package:foundit/providers/item_provider.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_shadows.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/widgets/app_bottom_nav.dart';

/// Peta interaktif OpenStreetMap: pin laporan + filter radius terdekat.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _bandung = LatLng(-6.9175, 107.6191);
  static const Distance _distance = Distance();

  final MapController _mapController = MapController();

  Position? _userPosition;
  bool _locating = false;
  bool _permissionDenied = false;
  double _radiusKm = 3;
  String _typeFilter = 'Semua';
  static const List<String> _types = <String>['Semua', 'Hilang', 'Ditemukan'];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _permissionDenied = true);
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userPosition = pos);
      _mapController.move(LatLng(pos.latitude, pos.longitude), 14);
    } catch (_) {
      if (mounted) setState(() => _permissionDenied = true);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  LatLng? get _userLatLng {
    final Position? pos = _userPosition;
    if (pos == null) return null;
    return LatLng(pos.latitude, pos.longitude);
  }

  List<ItemReport> _visibleReports(List<ItemReport> items) {
    final LatLng? user = _userLatLng;
    Iterable<ItemReport> result = items.where(
      (ItemReport r) => r.latitude != null && r.longitude != null,
    );
    if (_typeFilter != 'Semua') {
      final bool wantLost = _typeFilter == 'Hilang';
      result = result.where((ItemReport r) => r.isLost == wantLost);
    }
    final List<ItemReport> list = result.toList();
    if (user != null) {
      list.sort((ItemReport a, ItemReport b) {
        final double da = _distanceMeters(user, a);
        final double db = _distanceMeters(user, b);
        return da.compareTo(db);
      });
    }
    return list;
  }

  double _distanceMeters(LatLng from, ItemReport r) {
    return _distance.as(
      LengthUnit.Meter,
      from,
      LatLng(r.latitude!, r.longitude!),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void _onNav(int index) {
    switch (index) {
      case 0:
        Navigator.pop(context);
        break;
      case 2:
        Navigator.pushNamed(context, '/report');
        break;
      case 3:
        Navigator.pushNamed(context, '/chat');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
      default:
        break;
    }
  }

  void _openDetail(ItemReport report) {
    Navigator.pushNamed(context, '/detail', arguments: report);
  }

  void _showReportSheet(ItemReport report) {
    final LatLng? user = _userLatLng;
    final String? distanceText =
        user == null ? null : _formatDistance(_distanceMeters(user, report));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Row(
                  children: [
                    _typeBadge(report.isLost),
                    if (distanceText != null) ...[
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        distanceText,
                        style: AppTextStyles.labelM12.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(report.title, style: AppTextStyles.headingS17),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.s6),
                    Expanded(
                      child: Text(
                        report.location,
                        style: AppTextStyles.bodyM13.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (report.description != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    report.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS12.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _openDetail(report);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bgInverse,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Lihat Detail Laporan',
                      style: AppTextStyles.labelXl15.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _typeBadge(bool isLost) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLost ? AppColors.errorBg : AppColors.successBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isLost ? 'Hilang' : 'Ditemukan',
        style: AppTextStyles.labelS11.copyWith(
          color: isLost ? AppColors.error : AppColors.success,
        ),
      ),
    );
  }

  Marker _reportMarker(ItemReport report, int number) {
    final Color color = report.isLost ? AppColors.error : AppColors.success;
    return Marker(
      point: LatLng(report.latitude!, report.longitude!),
      width: 34,
      height: 34,
      child: GestureDetector(
        onTap: () => _showReportSheet(report),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: AppTextStyles.labelM12Semi.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ItemReport> allItems = context.watch<ItemProvider>().items;
    final LatLng? user = _userLatLng;
    final List<ItemReport> reports = _visibleReports(allItems);

    final List<ItemReport> nearby = user == null
        ? reports
        : reports
            .where(
              (ItemReport r) =>
                  _distanceMeters(user, r) <= _radiusKm * 1000,
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: user ?? _bandung,
                      initialZoom: user == null ? 12 : 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.foundit',
                      ),
                      if (user != null)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: user,
                              radius: _radiusKm * 1000,
                              useRadiusInMeter: true,
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderColor: AppColors.primary,
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          if (user != null)
                            Marker(
                              point: user,
                              width: 24,
                              height: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.mapUserLocation,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ...reports
                              .asMap()
                              .entries
                              .map((MapEntry<int, ItemReport> e) =>
                                  _reportMarker(e.value, e.key + 1)),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: AppSpacing.s12,
                    left: AppSpacing.s12,
                    right: AppSpacing.s12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: AppSpacing.s8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: AppRadius.lgAll,
                            boxShadow: AppShadows.barUp,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cari di sekitar Bandung',
                                style: AppTextStyles.titleL16.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s2),
                              Text(
                                'Lost Around Me',
                                style: AppTextStyles.caption10.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        _buildTypeChips(),
                        const SizedBox(height: AppSpacing.s8),
                        _buildRadiusSlider(),
                        if (_permissionDenied) ...[
                          const SizedBox(height: AppSpacing.s8),
                          _buildBanner(
                            'Aktifkan izin lokasi untuk melihat laporan '
                            'terdekat.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.s12 + 88,
                    right: AppSpacing.s12,
                    child: FloatingActionButton.small(
                      onPressed: _locating ? null : _initLocation,
                      backgroundColor: AppColors.bgSurface,
                      foregroundColor: AppColors.primary,
                      child: _locating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.s12,
                    right: AppSpacing.s12,
                    bottom: AppSpacing.s12,
                    child: _buildNearbyPanel(nearby),
                  ),
                ],
              ),
            ),
            AppBottomNav(
              selectedIndex: 1,
              onTap: _onNav,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChips() {
    return Row(
      children: _types.map((String type) {
        final bool selected = _typeFilter == type;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.s8),
          child: GestureDetector(
            onTap: () => setState(() => _typeFilter = type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                type,
                style: AppTextStyles.labelM12Semi.copyWith(
                  color: selected
                      ? AppColors.textOnBrand
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Radius pencarian',
              style: AppTextStyles.labelM12Semi.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_radiusKm.toStringAsFixed(0)} km',
              style: AppTextStyles.labelM12Semi.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.bgAccentSoft,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
            trackHeight: 6,
          ),
          child: Slider(
            value: _radiusKm,
            min: 1,
            max: 10,
            divisions: 9,
            label: '${_radiusKm.toStringAsFixed(0)} km',
            onChanged: (double v) => setState(() => _radiusKm = v),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_off_rounded,
            size: 16,
            color: AppColors.textWarning,
          ),
          const SizedBox(width: AppSpacing.s6),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.caption10.copyWith(
                color: AppColors.textWarning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPanel(List<ItemReport> nearby) {
    final LatLng? user = _userLatLng;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.barUp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Laporan Terdekat',
                style: AppTextStyles.titleM14,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                '${nearby.length}',
                style: AppTextStyles.labelM12.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          if (nearby.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: Text(
                'Tidak ada laporan dalam radius ${_radiusKm.toStringAsFixed(0)} km.',
                style: AppTextStyles.bodyS12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nearby.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.s8),
                itemBuilder: (BuildContext context, int index) {
                  final ItemReport r = nearby[index];
                  return GestureDetector(
                    onTap: () => _openDetail(r),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(AppSpacing.s10),
                      decoration: BoxDecoration(
                        color: AppColors.bgScreen,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            r.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelM12Semi.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Text(
                            user == null
                                ? r.location
                                : '${r.location} - ${_formatDistance(_distanceMeters(user, r))}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption10.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
