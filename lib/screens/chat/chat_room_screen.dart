import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:foundit/models/item_report.dart';
import 'package:foundit/services/chat_service.dart';
import 'package:foundit/services/image_upload_service.dart';
import 'package:foundit/services/reverse_geocoding.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/widgets/state_views.dart';
import 'package:foundit/widgets/top_banner.dart';

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
  String? _otherPhotoUrl;
  bool _chatReady = false;
  String? _chatError;
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
      final profile = await ChatService.userProfile(_otherUid);
      if (mounted) {
        setState(() {
          _chatReady = true;
          _otherName = profile.name;
          _otherPhotoUrl = profile.photoUrl;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _chatError = 'Gagal menyiapkan chat: $e');
    }
  }

  Future<void> _send() async {
    if (!_chatReady || _sending) return;
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
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
        TopBanner.error(context, 'Gagal mengirim pesan', message: '$e');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _shareLocation() async {
    if (!_chatReady || _sending) return;
    setState(() => _sending = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          TopBanner.error(context, 'Izin lokasi ditolak');
        }
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition();
      final String? place = await reverseGeocode(pos.latitude, pos.longitude);
      final String text = place == null
          ? 'Lokasi: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}'
          : 'Lokasi: $place';
      await ChatService.sendMessage(
        chatId: _chatId,
        senderUid: _uid,
        text: text,
      );
    } catch (e) {
      if (mounted) {
        TopBanner.error(context, 'Gagal membagikan lokasi', message: '$e');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sharePhoto() async {
    if (!_chatReady || _sending) return;
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;
      setState(() => _sending = true);
      final String url = await ImageUploadService.upload(picked);
      await ChatService.sendMessage(
        chatId: _chatId,
        senderUid: _uid,
        text: '',
        imageUrl: url,
      );
    } catch (e) {
      if (mounted) {
        TopBanner.error(context, 'Gagal mengirim foto', message: '$e');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _openShareSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_rounded,
                    color: AppColors.primary),
                title: const Text('Bagikan Lokasi'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _shareLocation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_rounded,
                    color: AppColors.primary),
                title: const Text('Bagikan Foto'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _sharePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.bgAccentSoft,
              backgroundImage: _otherPhotoUrl != null
                  ? NetworkImage(_otherPhotoUrl!)
                  : null,
              child: _otherPhotoUrl == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Column(
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
          : _chatError != null
              ? ErrorStateView(
                  message: _chatError!,
                  onRetry: () {
                    setState(() => _chatError = null);
                    _init();
                  },
                )
              : !_chatReady
                  ? const LoadingStateView(message: 'Menyiapkan chat...')
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
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 200,
                      height: 120,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) => const Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              if (message.text.isNotEmpty) const SizedBox(height: 4),
            ],
            if (message.text.isNotEmpty)
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
                GestureDetector(
                  onTap: _sending ? null : _openShareSheet,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.bgAccentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
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
