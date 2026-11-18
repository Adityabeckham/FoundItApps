import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/item_report.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/state_views.dart';

/// Ruang chat privat real-time antara pemilik laporan dan pengklaim.
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.ownerUid,
    required this.claimerUid,
  });

  final String itemId;
  final String itemTitle;
  final String ownerUid;
  final String claimerUid;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final DateFormat _timeFormat = DateFormat('HH:mm');

  late final String _uid;
  late final String _chatId;
  String? _otherName;
  bool _sending = false;

  bool get _isParticipant =>
      _uid == widget.ownerUid || _uid == widget.claimerUid;

  String get _otherUid =>
      _uid == widget.ownerUid ? widget.claimerUid : widget.ownerUid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _chatId = ChatService.chatId(widget.itemId, widget.claimerUid);
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (!_isParticipant) return;
    try {
      await ChatService.ensureChat(
        itemId: widget.itemId,
        itemTitle: widget.itemTitle,
        ownerUid: widget.ownerUid,
        claimerUid: widget.claimerUid,
      );
    } catch (_) {
      // abaikan; stream pesan tetap dicoba
    }
    final String name = await ChatService.displayName(_otherUid);
    if (mounted) setState(() => _otherName = name);
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ChatService.sendMessage(
        chatId: _chatId,
        senderUid: _uid,
        text: text,
      );
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _otherName ?? 'Memuat...',
              style: AppTextStyles.titleL16.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.itemTitle,
              style: AppTextStyles.caption10.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: !_isParticipant
          ? const EmptyStateView(
              icon: Icons.lock_rounded,
              title: 'Akses ditolak',
              message: 'Chat hanya tersedia untuk pemilik laporan dan '
                  'pengklaim yang telah disetujui.',
            )
          : Column(
              children: [
                Expanded(child: _buildMessages()),
                _buildInput(),
              ],
            ),
    );
  }

  Widget _buildMessages() {
    return StreamBuilder<List<ChatMessage>>(
      stream: ChatService.messagesStream(_chatId),
      builder: (BuildContext context,
          AsyncSnapshot<List<ChatMessage>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingStateView(message: 'Memuat pesan...');
        }
        if (snapshot.hasError) {
          return const ErrorStateView(
            message: 'Tidak dapat memuat pesan. Periksa koneksi internet.',
          );
        }
        final List<ChatMessage> messages = snapshot.data ?? <ChatMessage>[];
        if (messages.isEmpty) {
          return const EmptyStateView(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Belum ada pesan',
            message: 'Kirim pesan pertama untuk mengatur serah terima barang.',
          );
        }
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) {
            final ChatMessage message = messages[messages.length - 1 - index];
            return _bubble(message);
          },
        );
      },
    );
  }

  Widget _bubble(ChatMessage message) {
    final bool mine = message.senderUid == _uid;
    final String time = message.createdAt == null
        ? ''
        : _timeFormat.format(message.createdAt!.toLocal());

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.bgSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          border: mine ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.bodyM13.copyWith(
                color: mine ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: AppTextStyles.caption10.copyWith(
                color: mine ? AppColors.textOnBrandSoft : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s8,
        AppSpacing.s12,
        AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: AppTextStyles.bodyM13,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: AppTextStyles.bodyM13.copyWith(
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.bgScreen,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
