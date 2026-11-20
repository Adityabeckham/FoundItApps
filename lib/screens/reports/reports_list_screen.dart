import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundit/models/item_report.dart';
import 'package:foundit/providers/auth_provider.dart'as app_auth;
import 'package:foundit/providers/item_provider.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/widgets/report_card.dart';
import 'package:foundit/widgets/state_views.dart';

/// Layar daftar laporan: semua laporan atau milik pengguna.
class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({
    super.key,
    this.mine = false,
    this.title = 'Semua Laporan',
  });

  final bool mine;
  final String title;

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _queryController.text = context.read<ItemProvider>().query;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<ItemReport> _visible(ItemProvider ip, String? uid) {
    Iterable<ItemReport> result = ip.items;
    if (widget.mine && uid != null) {
      result = result.where((ItemReport r) => r.createdBy == uid);
    }
    final String q = ip.query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where(
        (ItemReport r) =>
            r.title.toLowerCase().contains(q) ||
            r.location.toLowerCase().contains(q) ||
            (r.description ?? '').toLowerCase().contains(q),
      );
    }
    // status filter from ItemProvider.filter
    if (ip.filter == 'Hilang') {
      result = result.where((ItemReport r) => r.isLost);
    } else if (ip.filter == 'Ditemukan') {
      result = result.where((ItemReport r) => !r.isLost);
    }
    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    final ItemProvider ip = context.watch<ItemProvider>();
    final String? uid = context.watch<app_auth.AuthProvider>().user?.uid;
    final List<ItemReport> reports = _visible(ip, uid);

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgScreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          widget.title,
          style: AppTextStyles.headingS17.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              0,
            ),
            child: TextField(
              controller: _queryController,
              onChanged: ip.setQuery,
              style: AppTextStyles.bodyM13,
              decoration: InputDecoration(
                hintText: 'Cari laporan...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              children: [
                _filterChip(context, ip, 'Semua'),
                const SizedBox(width: AppSpacing.s8),
                _filterChip(context, ip, 'Hilang'),
                const SizedBox(width: AppSpacing.s8),
                _filterChip(context, ip, 'Ditemukan'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Expanded(
            child: reports.isEmpty
                ? const EmptyStateView(
                    icon: Icons.inbox_rounded,
                    title: 'Tidak ada laporan',
                    message: 'Belum ada laporan yang sesuai.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.s20),
                    itemCount: reports.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ItemReport r = reports[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                        child: ReportCard(
                          report: r,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: r,
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

  Widget _filterChip(BuildContext context, ItemProvider ip, String label) {
    final bool selected = ip.filter == label;
    return GestureDetector(
      onTap: () => ip.setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.bgInverse : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.bgInverse : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelM12Semi.copyWith(
            color: selected ? AppColors.textOnBrand : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
