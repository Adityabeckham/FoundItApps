import 'package:flutter/material.dart';

import '../models/item_report.dart';
import '../data/dummy_reports.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Halaman Detail Laporan Barang.
class DetailReportScreen extends StatelessWidget {
  const DetailReportScreen({super.key, this.report});

  final ItemReport? report;

  @override
  Widget build(BuildContext context) {
    final ItemReport item = report ??
        (ModalRoute.of(context)?.settings.arguments as ItemReport?) ??
        dummyFallback();

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
              child: Row(
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      'Detail Laporan',
                      style: AppTextStyles.headingS17,
                    ),
                  ),
                  _circleButton(
                    icon: Icons.share_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s16,
                  AppSpacing.s20,
                  AppSpacing.s20,
                ),
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.xxlAll,
                    child: Container(
                      height: 220,
                      color: item.thumbBackground,
                      child: Image.asset(
                        item.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => const Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      _statusBadge(
                        item.isLost ? 'Hilang' : 'Ditemukan',
                        item.isLost ? AppColors.error : AppColors.success,
                        item.isLost ? AppColors.errorBg : AppColors.successBg,
                      ),
                      _statusBadge(
                        item.status,
                        AppColors.warning,
                        AppColors.warningBg,
                      ),
                      _statusBadge(
                        item.category,
                        AppColors.primary,
                        AppColors.bgAccentSoft,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(item.title, style: AppTextStyles.headingL22),
                  const SizedBox(height: AppSpacing.s12),
                  _infoRow(Icons.location_on_outlined, item.location),
                  const SizedBox(height: AppSpacing.s8),
                  _infoRow(Icons.access_time_rounded, item.timeAgo),
                  if (item.reward != null) ...[
                    const SizedBox(height: AppSpacing.s8),
                    _infoRow(Icons.card_giftcard_rounded, item.reward!),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: AppRadius.xlAll,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ciri khusus', style: AppTextStyles.titleM14),
                        const SizedBox(height: AppSpacing.s6),
                        Text(
                          'Gantungan kunci kulit warna cokelat dengan inisial huruf R. '
                          'Kunci terdiri dari 2 buah dengan remote alarm.',
                          style: AppTextStyles.bodyM13.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.bgSubtle,
                      borderRadius: AppRadius.xlAll,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.map_rounded,
                            size: 32,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Lihat di peta',
                            style: AppTextStyles.labelM12.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s14),
                    decoration: BoxDecoration(
                      color: AppColors.bgAccentSoft,
                      borderRadius: AppRadius.lgAll,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.textBrand,
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Expanded(
                          child: Text(
                            'Penemu membuat pertanyaan rahasia. Jawab dengan benar '
                            'untuk membuka chat. Maksimal 3 kali percobaan.',
                            style: AppTextStyles.bodyS12.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s12,
                AppSpacing.s20,
                AppSpacing.s20,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                boxShadow: AppShadows.barUp,
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bgInverse,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    icon: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Klaim Barang',
                      style: AppTextStyles.labelXl15.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _statusBadge(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelS11.copyWith(color: fg),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.s10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyM13.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

ItemReport dummyFallback() => dummyReports.first;


