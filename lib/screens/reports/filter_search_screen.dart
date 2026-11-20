import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:foundit/providers/item_provider.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';

/// Layar Filter & Pencarian sesuai desain FoundIt.
class FilterSearchScreen extends StatefulWidget {
  const FilterSearchScreen({super.key});

  @override
  State<FilterSearchScreen> createState() => _FilterSearchScreenState();
}

class _FilterSearchScreenState extends State<FilterSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _locating = false;

  static const List<String> _categories = <String>[
    'Semua',
    'Dompet',
    'Kunci',
    'Elektronik',
    'Tas',
    'Aksesoris',
    'Lainnya',
  ];

  static const List<String> _statuses = <String>[
    'Semua',
    'Hilang',
    'Ditemukan',
  ];

  static const List<String> _sorts = <String>[
    'Terbaru',
    'Terdekat',
    'Imbalan tertinggi',
  ];

  @override
  void initState() {
    super.initState();
    final ItemProvider ip = context.read<ItemProvider>();
    _queryController.text = ip.query;
    _initLocation(ip);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _initLocation(ItemProvider ip) async {
    if (ip.userLat != null) return;
    setState(() => _locating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      ip.setUserLocation(pos.latitude, pos.longitude);
    } catch (_) {
      // abaikan; radius filter dinonaktifkan
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _reset(ItemProvider ip) {
    _queryController.clear();
    ip.setQuery('');
    ip.setStatusFilter('Semua');
    ip.setCategoryFilter('Semua');
    ip.setSortMode('Terbaru');
    ip.setRadiusKm(null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (BuildContext context, ItemProvider ip, _) {
        return Scaffold(
          backgroundColor: AppColors.bgScreen,
          appBar: AppBar(
            backgroundColor: AppColors.bgScreen,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            title: Text(
              'Filter Pencarian',
              style: AppTextStyles.headingS17.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.s20),
            children: [
              // Lokasi
              _sectionTitle('Lokasi'),
              const SizedBox(height: AppSpacing.s8),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lokasi pencarian: Bandung'),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: AppColors.borderBrand),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          'Bandung',
                          style: AppTextStyles.bodyM13.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                '${ip.filteredItems.length} hasil pencarian',
                style: AppTextStyles.caption10.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              // Kata kunci
              const SizedBox(height: AppSpacing.s20),
              _sectionTitle('Kata Kunci'),
              const SizedBox(height: AppSpacing.s8),
              TextField(
                controller: _queryController,
                onChanged: ip.setQuery,
                style: AppTextStyles.bodyM13,
                decoration: InputDecoration(
                  hintText: 'Cari barang hilang atau ditemukan',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              // Kategori
              const SizedBox(height: AppSpacing.s20),
              _sectionTitle('Kategori'),
              const SizedBox(height: AppSpacing.s8),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: _categories.map((String c) {
                  final bool selected = ip.categoryFilter == c;
                  return _chip(
                    label: c,
                    selected: selected,
                    onTap: () => ip.setCategoryFilter(c),
                  );
                }).toList(),
              ),

              // Status
              const SizedBox(height: AppSpacing.s20),
              _sectionTitle('Status'),
              const SizedBox(height: AppSpacing.s8),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: _statuses.map((String s) {
                  final bool selected = ip.statusFilter == s;
                  return _chip(
                    label: s,
                    selected: selected,
                    onTap: () => ip.setStatusFilter(s),
                  );
                }).toList(),
              ),

              // Radius
              const SizedBox(height: AppSpacing.s20),
              _sectionTitle('Radius dari lokasimu'),
              const SizedBox(height: AppSpacing.s8),
              if (_locating)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
                  child: LinearProgressIndicator(minHeight: 2),
                )
              else if (ip.userLat == null)
                Text(
                  'Aktifkan izin lokasi untuk memakai radius.',
                  style: AppTextStyles.caption10.copyWith(
                    color: AppColors.textMuted,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Radius',
                          style: AppTextStyles.labelM12Semi.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ip.radiusKm == null
                              ? 'Semua'
                              : '${ip.radiusKm!.toStringAsFixed(0)} km',
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
                        value: (ip.radiusKm ?? 10).clamp(1.0, 10.0),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: ip.radiusKm == null
                            ? 'Semua'
                            : '${ip.radiusKm!.toStringAsFixed(0)} km',
                        onChanged: (double v) => ip.setRadiusKm(v),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 km',
                          style: AppTextStyles.caption10.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ip.setRadiusKm(null),
                          child: Text(
                            'Semua',
                            style: AppTextStyles.caption10.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          '10 km',
                          style: AppTextStyles.caption10.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              // Urutkan
              const SizedBox(height: AppSpacing.s20),
              _sectionTitle('Urutkan'),
              const SizedBox(height: AppSpacing.s8),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: _sorts.map((String s) {
                  final bool selected = ip.sortMode == s;
                  return _chip(
                    label: s,
                    selected: selected,
                    onTap: () => ip.setSortMode(s),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.s32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _reset(ip),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdAll,
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: AppTextStyles.labelM12Semi.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bgInverse,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdAll,
                        ),
                      ),
                      child: Text(
                        'Terapkan Filter',
                        style: AppTextStyles.labelM12Semi.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: AppTextStyles.titleM14);
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          label,
          style: AppTextStyles.labelM12Semi.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
