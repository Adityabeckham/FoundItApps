import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/state_views.dart';

/// Halaman daftar chat privat FoundIt.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

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
          'Chat',
          style: AppTextStyles.headingS17.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: const EmptyStateView(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Belum ada chat',
        message: 'Chat dengan pemilik atau penemu barang akan muncul di sini '
            'setelah klaim terverifikasi.',
      ),
    );
  }
}
