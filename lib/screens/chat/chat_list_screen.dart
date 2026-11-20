import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:foundit/services/chat_service.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/utils/app_transitions.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/widgets/state_views.dart';
import 'package:foundit/screens/chat/chat_room_screen.dart';

/// Halaman daftar chat privat FoundIt.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? uid;
    try {
      uid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      uid = null;
    }

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
      body: uid == null
          ? const EmptyStateView(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Belum ada chat',
              message: 'Chat tersedia setelah klaim barang disetujui.',
            )
          : _buildList(context, uid),
    );
  }

  Widget _buildList(BuildContext context, String uid) {
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: ChatService.chatsForUser(uid),
      builder: (BuildContext context,
          AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
              snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingStateView(message: 'Memuat chat...');
        }
        if (snapshot.hasError) {
          return const ErrorStateView(
            message: 'Tidak dapat memuat chat. Periksa koneksi internet.',
          );
        }
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snapshot.data ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        if (docs.isEmpty) {
          return const EmptyStateView(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Belum ada chat',
            message: 'Chat tersedia setelah klaim barang disetujui.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.s20),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (BuildContext context, int index) {
            return _chatTile(context, docs[index]);
          },
        );
      },
    );
  }

  Widget _chatTile(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> d = doc.data();
    final String itemId = (d['itemId'] as String?) ?? '';
    final String itemTitle = (d['itemTitle'] as String?) ?? 'Laporan';
    final String ownerUid = (d['ownerUid'] as String?) ?? '';
    final String claimerUid = (d['claimerUid'] as String?) ?? '';
    final String lastMessage = (d['lastMessage'] as String?) ?? '';
    final Timestamp? updatedAt = d['updatedAt'] as Timestamp?;

    final String time = updatedAt == null
        ? ''
        : DateFormat('HH:mm').format(updatedAt.toDate().toLocal());

    return GestureDetector(
      onTap: () => pushSlide(
        context,
        ChatRoomScreen(
          itemId: itemId,
          itemTitle: itemTitle,
          ownerUid: ownerUid,
          claimerUid: claimerUid,
        ),
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
              decoration: const BoxDecoration(
                color: AppColors.bgAccentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleM14,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage.isEmpty ? 'Mulai percakapan' : lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              time,
              style: AppTextStyles.caption10.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
