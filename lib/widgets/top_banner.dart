import 'package:flutter/material.dart';

import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';

/// Banner notifikasi di bagian atas layar (Overlay), auto-dismiss.
class TopBanner {
  TopBanner._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String title,
    String? message,
    Color background = AppColors.bgSurface,
    Color foreground = AppColors.textPrimary,
    IconData icon = Icons.info_rounded,
    Color iconColor = AppColors.primary,
    Duration duration = const Duration(seconds: 3),
  }) {
    _current?.remove();
    _current = null;

    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    final AnimationController controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 260),
    );
    final Animation<Offset> offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    entry = OverlayEntry(
      builder: (BuildContext ctx) {
        return Positioned(
          top: MediaQuery.of(ctx).padding.top + AppSpacing.s12,
          left: AppSpacing.s16,
          right: AppSpacing.s16,
          child: SlideTransition(
            position: offset,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: AppRadius.lgAll,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: iconColor, size: 22),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.labelM12Semi.copyWith(
                              color: foreground,
                            ),
                          ),
                          if (message != null && message.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              message,
                              style: AppTextStyles.bodyS12.copyWith(
                                color: foreground.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _current = entry;
    controller.forward();

    Future<void>.delayed(duration, () async {
      if (_current != entry) return;
      await controller.reverse();
      entry.remove();
      if (_current == entry) _current = null;
      controller.dispose();
    });
  }

  static void success(BuildContext context, String title, {String? message}) {
    show(
      context,
      title: title,
      message: message,
      background: AppColors.successBg,
      foreground: AppColors.textPrimary,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
    );
  }

  static void error(BuildContext context, String title, {String? message}) {
    show(
      context,
      title: title,
      message: message,
      background: AppColors.errorBg,
      foreground: AppColors.textPrimary,
      icon: Icons.error_rounded,
      iconColor: AppColors.error,
    );
  }

  static void info(BuildContext context, String title, {String? message}) {
    show(
      context,
      title: title,
      message: message,
      background: AppColors.bgAccentSoft,
      foreground: AppColors.textPrimary,
      icon: Icons.info_rounded,
      iconColor: AppColors.primary,
    );
  }
}
