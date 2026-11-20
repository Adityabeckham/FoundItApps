import 'package:flutter/material.dart';

import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_text_styles.dart';

/// Badge status laporan: Hilang (merah) atau Ditemukan (hijau).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.isLost});

  final bool isLost;

  @override
  Widget build(BuildContext context) {
    final Color background = isLost ? AppColors.errorBg : AppColors.successBg;
    final Color foreground = isLost ? AppColors.error : AppColors.success;
    final String label = isLost ? 'Hilang' : 'Ditemukan';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelS11.copyWith(color: foreground),
      ),
    );
  }
}

