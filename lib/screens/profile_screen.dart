import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as app_auth;
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

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

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos/${user.uid}.jpg');
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(file.path));
      }
      final String url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
      await user.reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil diperbarui.')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _saveName() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong.')),
      );
      return;
    }
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      await user?.updateDisplayName(name);
      await user?.reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama profil diperbarui.')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan nama: $e')),
        );
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

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s20),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColors.bgAccentSoft,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 56,
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
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: _uploading
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text('Nama', style: AppTextStyles.titleM14),
            const SizedBox(height: AppSpacing.s8),
            TextField(
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
            const SizedBox(height: AppSpacing.s32),
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
                  'Logout',
                  style: AppTextStyles.labelXl15.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

