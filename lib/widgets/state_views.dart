import 'package:flutter/material.dart';

import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';

/// Empty state konsisten untuk FoundIt (data kosong / tidak ada hasil).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateContainer(
      icon: icon,
      iconColor: AppColors.primary,
      iconBackground: AppColors.bgAccentSoft,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Loading indicator konsisten selama proses pengambilan data.
class LoadingStateView extends StatelessWidget {
  const LoadingStateView({
    super.key,
    this.message = 'Memuat data...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            message,
            style: AppTextStyles.bodyM13.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state konsisten (mis. network error / kegagalan Firestore).
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    this.title = 'Gagal memuat data',
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateContainer(
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      iconBackground: AppColors.errorBg,
      title: title,
      message: message,
      actionLabel: onRetry != null ? 'Coba Lagi' : null,
      onAction: onRetry,
    );
  }
}

class _StateContainer extends StatelessWidget {
  const _StateContainer({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleL16.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM13.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.s20),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnBrand,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.fullAll,
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.labelM12Semi.copyWith(
                      color: AppColors.textOnBrand,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
