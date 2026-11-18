import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/item_report.dart';
import '../services/claim_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/state_views.dart';
import 'claim_screen.dart';

/// Halaman Detail Laporan Barang.
class DetailReportScreen extends StatelessWidget {
  const DetailReportScreen({super.key, this.report});

  final ItemReport? report;

  @override
  Widget build(BuildContext context) {
    final ItemReport? resolved = report ??
        (ModalRoute.of(context)?.settings.arguments as ItemReport?);

    if (resolved == null) {
      return Scaffold(
        backgroundColor: AppColors.bgScreen,
        appBar: AppBar(
          backgroundColor: AppColors.bgScreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            'Detail Laporan',
            style: AppTextStyles.headingS17.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: EmptyStateView(
          icon: Icons.search_off_rounded,
          title: 'Laporan tidak ditemukan',
          message: 'Data laporan tidak tersedia atau telah dihapus.',
          actionLabel: 'Kembali',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    final ItemReport item = resolved;

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
                      child: _reportImage(item),
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
                        Text('Deskripsi Barang', style: AppTextStyles.titleM14),
                        const SizedBox(height: AppSpacing.s6),
                        Text(
                          item.description ??
                          'Tidak ada ciri khusus yang dicantumkan.',
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
            if (_canClaim(item)) _buildClaimBar(context, item),
          ],
        ),
      ),
    );
  }

  Widget _reportImage(ItemReport item) {
    final String src = item.imageAsset;
    final bool isNetwork =
        src.startsWith('http://') || src.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stack) => _imageError(),
      );
    }
    return Image.asset(
      src,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _imageError(),
    );
  }

  Widget _imageError() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_rounded,
        size: 48,
        color: AppColors.textMuted,
      ),
    );
  }

  bool _canClaim(ItemReport item) {
    String? uid;
    try {
      uid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      uid = null;
    }
    return item.id != null &&
        uid != null &&
        !item.isLost &&
        item.createdBy != uid &&
        item.status != ReportStatus.resolved;
  }

  Widget _buildClaimBar(BuildContext context, ItemReport item) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ClaimService.claimStream(item.id!, uid),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        final Map<String, dynamic>? data = snapshot.data?.data();
        final int attempts = (data?['attempts'] as num?)?.toInt() ?? 0;
        final String status =
            (data?['status'] as String?) ?? ClaimStatus.pending;
        final bool approved = status == ClaimStatus.approved;
        final bool locked = attempts >= ClaimService.maxAttempts && !approved;

        final String label;
        if (approved) {
          label = 'Buka Chat';
        } else if (locked) {
          label = 'Klaim Terkunci (Limit Exceeded)';
        } else {
          label = 'Klaim Barang';
        }

        return Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!approved && !locked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                    child: Text(
                      'Sisa ${ClaimService.maxAttempts - attempts} dari '
                      '${ClaimService.maxAttempts} percobaan klaim.',
                      style: AppTextStyles.caption10.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: locked
                        ? null
                        : () {
                            if (approved) {
                              Navigator.pushNamed(context, '/chat');
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => ClaimScreen(item: item),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: approved
                          ? AppColors.success
                          : AppColors.bgInverse,
                      disabledBackgroundColor: AppColors.bgSubtle,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    icon: Icon(
                      approved
                          ? Icons.chat_bubble_rounded
                          : locked
                              ? Icons.lock_rounded
                              : Icons.verified_rounded,
                      color: locked ? AppColors.textMuted : Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      label,
                      style: AppTextStyles.labelXl15.copyWith(
                        color: locked ? AppColors.textMuted : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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




