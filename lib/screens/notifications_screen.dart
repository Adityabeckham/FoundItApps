import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/state_views.dart';

/// Halaman daftar notifikasi FoundIt.
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
      body: const EmptyStateView(
        icon: Icons.notifications_none_rounded,
        title: 'Belum ada notifikasi',
        message: 'Notifikasi tentang laporan dan klaim barang akan muncul '
            'di sini.',
      ),
    );
  }
}
