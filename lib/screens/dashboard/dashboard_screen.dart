import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundit/models/item_report.dart';
import 'package:foundit/providers/auth_provider.dart';
import 'package:foundit/providers/item_provider.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/widgets/app_bottom_nav.dart';
import 'package:foundit/widgets/report_card.dart';
import 'package:foundit/widgets/state_views.dart';
import 'package:foundit/widgets/top_banner.dart';

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
    'Kunci',
    'Elektronik',
    'Tas',
    'Aksesoris',
    'Lainnya',
  ];

  int _navIndex = 0;
  String? _shownError;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ItemProvider itemProvider = context.watch<ItemProvider>();
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final List<ItemReport> reports = itemProvider.filteredItems;

    _maybeShowError(context, itemProvider.error);

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
              child: _buildHeader(authProvider.displayName),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s16,
                AppSpacing.s20,
                0,
              ),
              child: _buildSearchRow(itemProvider),
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
                itemBuilder: (context, index) =>
                    _buildFilterChip(index, itemProvider),
              ),
            ),
            Expanded(
              child: _buildContent(context, itemProvider, reports),
            ),
            AppBottomNav(
              selectedIndex: _navIndex,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushNamed(context, '/map');
                  return;
                }
                if (index == 2) {
                  Navigator.pushNamed(context, '/report');
                  return;
                }
                if (index == 3) {
                  Navigator.pushNamed(context, '/chat');
                  return;
                }
                if (index == 4) {
                  Navigator.pushNamed(context, '/profile');
                  return;
                }
                setState(() => _navIndex = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _maybeShowError(BuildContext context, String? error) {
    if (error == null || error == _shownError) return;
    _shownError = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      TopBanner.error(
        context,
        'Gagal memuat data',
        message: error,
      );
    });
  }

  Widget _buildContent(
    BuildContext context,
    ItemProvider itemProvider,
    List<ItemReport> reports,
  ) {
    if (itemProvider.isLoading && reports.isEmpty) {
      return const LoadingStateView(message: 'Memuat laporan...');
    }
    if (itemProvider.error != null && reports.isEmpty) {
      return ErrorStateView(
        message: itemProvider.error!,
        onRetry: itemProvider.retry,
      );
    }

    final bool hasActiveFilter =
        itemProvider.query.trim().isNotEmpty || itemProvider.filter != 'Semua';

    return Column(
      children: [
        if (itemProvider.isLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            color: AppColors.primary,
            backgroundColor: AppColors.bgAccentSoft,
          ),
        Expanded(
          child: reports.isEmpty
              ? EmptyStateView(
                  icon: hasActiveFilter
                      ? Icons.search_off_rounded
                      : Icons.inbox_rounded,
                  title: hasActiveFilter
                      ? 'Laporan tidak ditemukan'
                      : 'Belum ada laporan',
                  message: hasActiveFilter
                      ? 'Coba ubah kata kunci atau filter kategori.'
                      : 'Belum ada laporan barang. Jadilah yang pertama '
                          'melaporkan.',
                  actionLabel: hasActiveFilter ? 'Reset Filter' : null,
                  onAction: hasActiveFilter
                      ? () {
                          _searchController.clear();
                          itemProvider.setQuery('');
                          itemProvider.setFilter('Semua');
                        }
                      : null,
                )
              : ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s8,
                  ),
                  children: [
                    _buildSectionHeader(),
                    const SizedBox(height: AppSpacing.s12),
                    ...reports.map(
                      (report) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                        child: ReportCard(
                          report: report,
                          onTap: () => Navigator.pushNamed(
                            context, '/detail', arguments: report),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(String name) {
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
                name,
                style: AppTextStyles.titleL16,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/notifications'),
          child: Container(
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
        ),
      ],
    );
  }

  Widget _buildSearchRow(ItemProvider itemProvider) {
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
                    controller: _searchController,
                    onChanged: itemProvider.setQuery,
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
          onTap: () => Navigator.pushNamed(context, '/filter-search'),
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

  Widget _buildFilterChip(int index, ItemProvider itemProvider) {
    final bool selected = itemProvider.filter == _filters[index];
    return GestureDetector(
          onTap: () => itemProvider.setFilter(_filters[index]),
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
            onTap: () => Navigator.pushNamed(context, '/all-reports'),
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





