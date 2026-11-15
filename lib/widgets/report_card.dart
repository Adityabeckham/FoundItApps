import 'package:flutter/material.dart';

import '../models/item_report.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'status_badge.dart';

/// Kartu ringkas satu laporan barang untuk katalog dashboard.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report, this.onTap});

  final ItemReport report;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: AppRadius.xlAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.lgAll,
              child: Container(
                width: 72,
                height: 72,
                color: report.thumbBackground,
                child: Image.asset(
                  report.imageAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(isLost: report.isLost),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        report.timeAgo,
                        style: AppTextStyles.caption10,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    report.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleM14,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          report.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyS12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.iconMuted,
            ),
          ],
        ),
      ),
    );
  }
}

