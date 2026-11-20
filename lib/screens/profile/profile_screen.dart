import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:foundit/data/firestore_collections.dart';
import 'package:foundit/models/item_report.dart';
import 'package:foundit/providers/auth_provider.dart'as app_auth;
import 'package:foundit/providers/item_provider.dart';
import 'package:foundit/services/claim_service.dart';
import 'package:foundit/services/image_upload_service.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/widgets/top_banner.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';

/// Halaman Profil Dasar: tampilkan & edit nama/foto, logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final String url = await ImageUploadService.upload(file);
      await user.updatePhotoURL(url);
      await user.reload();
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set(<String, dynamic>{
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        TopBanner.success(context, 'Foto profil diperbarui');
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        TopBanner.error(context, 'Gagal mengunggah foto', message: '$e');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _saveName() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      TopBanner.error(context, 'Nama wajib diisi',
          message: 'Nama tidak boleh kosong.');
      return;
    }
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      await user?.updateDisplayName(name);
      await user?.reload();
      if (user != null) {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(user.uid)
            .set(<String, dynamic>{
          'displayName': name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      if (mounted) {
        TopBanner.success(context, 'Nama profil diperbarui');
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        TopBanner.error(context, 'Gagal menyimpan nama', message: '$e');
      }
    }
  }

  Future<void> _logout() async {
    await context.read<app_auth.AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoUrl = user?.photoURL;
    final String uid = user?.uid ?? '';
    final ItemProvider itemProvider = context.watch<ItemProvider>();

    final List<ItemReport> myItems = uid.isEmpty
        ? const <ItemReport>[]
        : itemProvider.items
            .where((ItemReport r) => r.createdBy == uid)
            .toList();
    final int totalReports = myItems.length;
    final int resolved = myItems
        .where((ItemReport r) => r.status == ReportStatus.resolved)
        .length;

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgScreen,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Profil',
          style: AppTextStyles.headingS17.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s20),
          children: [
            // Avatar + nama + email + edit profil
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.bgAccentSoft,
                        backgroundImage:
                            photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 44,
                                color: AppColors.textMuted,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _uploading ? null : _pickAndUploadPhoto,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: _uploading
                                ? const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    user?.displayName ?? 'Pengguna',
                    style: AppTextStyles.headingS17.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '-',
                    style: AppTextStyles.bodyS12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: () => _nameFocus.requestFocus(),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit Profil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.borderBrand),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.fullAll,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            // Stats
            Row(
              children: [
                Expanded(
                  child: _statCard('Laporan', '$totalReports'),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: _statCard('Selesai', '$resolved'),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _countApprovedClaims(uid),
                    builder: (context, snap) {
                      return _statCard('Klaim', '${snap.data ?? 0}');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            // Edit nama
            Text('Nama', style: AppTextStyles.titleM14),
            const SizedBox(height: AppSpacing.s8),
            TextField(
              focusNode: _nameFocus,
              controller: _nameController,
              style: AppTextStyles.bodyM13,
              decoration: InputDecoration(
                hintText: 'Nama tampilan',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save_rounded),
                  onPressed: _saveName,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text('Email', style: AppTextStyles.titleM14),
            const SizedBox(height: AppSpacing.s8),
            Text(
              user?.email ?? '-',
              style: AppTextStyles.bodyM13.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            // Laporan Saya
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/my-reports'),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Laporan Saya', style: AppTextStyles.titleL16),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            if (myItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Belum ada laporan yang kamu buat.',
                  style: AppTextStyles.bodyS12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...myItems.map(
                (ItemReport r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: r,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
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
                              color: r.thumbBackground,
                              borderRadius: AppRadius.mdAll,
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelM12Semi.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  r.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption10.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _statusPill(r.isLost ? 'Hilang' : 'Ditemukan'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.s20),
            // Settings rows
            _settingsRow(
              Icons.notifications_none_rounded,
              'Pengaturan Notifikasi',
              onTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
            _settingsRow(
              Icons.lock_outline_rounded,
              'Privasi Kontak',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privasi kontak (segera hadir).')),
              ),
            ),
            _settingsRow(
              Icons.help_outline_rounded,
              'Bantuan',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bantuan (segera hadir).')),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: Text(
                  'Keluar',
                  style: AppTextStyles.labelXl15.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headingS17.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption10.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label) {
    final bool lost = label == 'Hilang';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: lost ? AppColors.errorBg : AppColors.successBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelS11.copyWith(
          color: lost ? AppColors.error : AppColors.success,
        ),
      ),
    );
  }

  Widget _settingsRow(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s14,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelM12Semi.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _countApprovedClaims(String uid) async {
    if (uid.isEmpty) return 0;
    try {
      final snap = await ClaimService.claimsForUser(uid).first;
      return snap.where((d) => d.data()['status'] == ClaimStatus.approved).length;
    } catch (_) {
      return 0;
    }
  }
}

