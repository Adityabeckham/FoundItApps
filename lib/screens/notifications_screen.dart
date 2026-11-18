import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/dummy_reports.dart';
import '../models/item_report.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Halaman notifikasi FoundIt + simulasi notifikasi lokal dari data seed.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgScreen,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Notifikasi',
          style: AppTextStyles.headingS17.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s14),
            decoration: BoxDecoration(
              color: AppColors.bgAccentSoft,
              borderRadius: AppRadius.lgAll,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.textBrand,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: Text(
                    'Notifikasi lokal memberi tahu saat ada barang temuan '
                    'yang cocok atau klaim baru pada laporanmu.',
                    style: AppTextStyles.bodyS12.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          Text('Simulasikan Notifikasi', style: AppTextStyles.titleM14),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Menggunakan data seed lokal untuk demonstrasi.',
            style: AppTextStyles.caption10,
          ),
          const SizedBox(height: AppSpacing.s12),
          _simulationTile(
            context,
            icon: Icons.search_rounded,
            color: AppColors.error,
            background: AppColors.errorBg,
            title: 'Barang Temuan Cocok',
            subtitle: 'Barang temuan yang cocok dengan laporan kehilangan.',
            onTap: () => _simulateMatch(context),
          ),
          const SizedBox(height: AppSpacing.s12),
          _simulationTile(
            context,
            icon: Icons.verified_rounded,
            color: AppColors.success,
            background: AppColors.successBg,
            title: 'Klaim Baru',
            subtitle: 'Ada klaim baru pada salah satu laporanmu.',
            onTap: () => _simulateClaim(context),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: AppSpacing.s20),
            Text(
              'Catatan: notifikasi sistem hanya tampil di perangkat Android. '
              'Di web, simulasi hanya menampilkan konfirmasi.',
              style: AppTextStyles.caption10.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _simulationTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color background,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleM14),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateMatch(BuildContext context) async {
    final ItemReport found = dummyReports.firstWhere(
      (ItemReport r) => !r.isLost,
      orElse: () => dummyReports.first,
    );
    final ItemReport lost = dummyReports.firstWhere(
      (ItemReport r) => r.isLost,
      orElse: () => dummyReports.first,
    );
    await NotificationService.showMatchNotification(found, lost: lost);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notifikasi temuan cocok dikirim: ${found.title}')),
    );
  }

  Future<void> _simulateClaim(BuildContext context) async {
    final ItemReport item = dummyReports.firstWhere(
      (ItemReport r) => !r.isLost,
      orElse: () => dummyReports.first,
    );
    await NotificationService.showClaimNotification(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notifikasi klaim baru dikirim: ${item.title}')),
    );
  }
}
