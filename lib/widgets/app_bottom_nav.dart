import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Bottom navigation custom FoundIt (bar navy dengan tombol Lapor di tengah).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const List<({IconData icon, String label})> _items = [
    (icon: Icons.home_rounded, label: 'Beranda'),
    (icon: Icons.map_rounded, label: 'Peta'),
    (icon: Icons.add_rounded, label: 'Lapor'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
    (icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgInverse,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.barUp,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          return _buildItem(index);
        }),
      ),
    );
  }

  Widget _buildItem(int index) {
    final ({IconData icon, String label}) item = _items[index];
    final bool isReport = index == 2;
    final bool isActive = index == selectedIndex;

    if (isReport) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 26,
                color: AppColors.textOnBrand,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              item.label,
              style: AppTextStyles.caption10.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final Color color =
        isActive ? AppColors.primary : AppColors.textMuted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 22, color: color),
          const SizedBox(height: AppSpacing.s4),
          Text(
            item.label,
            style: AppTextStyles.caption10.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

