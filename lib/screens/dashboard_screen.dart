import 'package:flutter/material.dart';

import '../data/dummy_reports.dart';
import '../models/item_report.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/report_card.dart';

/// Halaman Beranda (Dashboard Katalog) setelah pengguna login.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<String> _filters = [
    'Semua',
    'Hilang',
    'Ditemukan',
    'Dompet',
    'Elektronik',
    'Kunci',
  ];

  int _filterIndex = 0;
  int _navIndex = 0;

  List<ItemReport> get _filteredReports {
    switch (_filterIndex) {
      case 1:
        return dummyReports.where((report) => report.isLost).toList();
      case 2:
        return dummyReports.where((report) => !report.isLost).toList();
      case 3:
        return dummyReports
            .where((report) => report.category == 'Dompet')
            .toList();
      case 4:
        return dummyReports
            .where((report) => report.category == 'Elektronik')
            .toList();
      case 5:
        return dummyReports
            .where((report) => report.category == 'Kunci')
            .toList();
      default:
        return dummyReports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ItemReport> reports = _filteredReports;

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s12,
                AppSpacing.s20,
                0,
              ),
              child: _buildHeader(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s16,
                AppSpacing.s20,
                0,
              ),
              child: _buildSearchRow(),
            ),
            const SizedBox(height: AppSpacing.s16),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s20,
                ),
                itemCount: _filters.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.s8),
                itemBuilder: (context, index) => _buildFilterChip(index),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s20,
                  AppSpacing.s20,
                  AppSpacing.s8,
                ),
                children: [
                  _buildSectionHeader(),
                  const SizedBox(height: AppSpacing.s12),
                  if (reports.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Belum ada laporan',
                          style: AppTextStyles.bodyM13.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    ...reports.map(
                      (report) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                        child: ReportCard(
                          report: report,
                          onTap: () {},
                        ),
                      ),
                    ),
                ],
              ),
            ),
            AppBottomNav(
              selectedIndex: _navIndex,
              onTap: (index) => setState(() => _navIndex = index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo,',
                style: AppTextStyles.bodyM13.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Aditya Beckham',
                style: AppTextStyles.titleL16,
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: TextField(
                    style: AppTextStyles.bodyM13,
                    decoration: InputDecoration(
                      hintText: 'Cari barang hilang atau ditemukan',
                      hintStyle: AppTextStyles.bodyM13.copyWith(
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s10),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.bgInverse,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: AppColors.textOnBrand,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(int index) {
    final bool selected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.bgInverse : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.bgInverse : AppColors.border,
          ),
        ),
        child: Text(
          _filters[index],
          style: AppTextStyles.labelM12Semi.copyWith(
            color: selected ? AppColors.textOnBrand : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Laporan Terbaru',
            style: AppTextStyles.titleL16,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Lihat semua',
            style: AppTextStyles.labelM12.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

