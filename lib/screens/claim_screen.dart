import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item_report.dart';
import '../services/claim_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/state_views.dart';

/// Halaman klaim barang dengan verifikasi pertanyaan rahasia (maks. 3x).
class ClaimScreen extends StatefulWidget {
  const ClaimScreen({super.key, required this.item});

  final ItemReport item;

  @override
  State<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends State<ClaimScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final String _uid;
  late final List<TextEditingController> _answerControllers;

  Claim? _claim;
  bool _loading = true;
  bool _submitting = false;
  bool _uploadingProof = false;
  bool _resolving = false;
  bool _resolved = false;
  String? _proofUrl;
  String? _error;

  bool get _hasQuestions =>
      widget.item.secretQuestions.isNotEmpty &&
      widget.item.secretAnswers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _answerControllers = List<TextEditingController>.generate(
      widget.item.secretQuestions.length,
      (_) => TextEditingController(),
    );
    _loadClaim();
  }

  @override
  void dispose() {
    for (final TextEditingController c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadClaim() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (widget.item.id == null || _uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc = await ClaimService.claimRef(widget.item.id!, _uid).get();
      if (!mounted) return;
      final Map<String, dynamic>? d = doc.data();
      setState(() {
        if (d != null) {
          _claim = Claim(
            id: doc.id,
            itemId: widget.item.id!,
            claimerUid: _uid,
            answers: (d['answers'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const <String>[],
            attempts: (d['attempts'] as num?)?.toInt() ?? 0,
            status: (d['status'] as String?) ?? ClaimStatus.pending,
            rejectionReason: d['rejectionReason'] as String?,
            proofUrl: d['proofUrl'] as String?,
          );
          _proofUrl = _claim?.proofUrl;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat status klaim: $e';
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final List<String> answers = _answerControllers
          .map((TextEditingController c) => c.text.trim())
          .toList();
      final Claim claim = await ClaimService.submitClaim(
        item: widget.item,
        answers: answers,
        uid: _uid,
        currentAttempts: _claim?.attempts ?? 0,
      );
      if (!mounted) return;
      setState(() => _claim = claim);

      if (claim.status == ClaimStatus.approved) {
        _snack('Klaim disetujui. Kamu bisa membuka chat dengan pemilik.');
      } else if (claim.status == ClaimStatus.rejected) {
        _snack('Klaim ditolak: Limit Exceeded.');
      } else {
        _snack('Jawaban salah. Sisa ${claim.remainingAttempts} percobaan.');
        for (final TextEditingController c in _answerControllers) {
          c.clear();
        }
      }
    } catch (e) {
      _snack('Gagal memproses klaim: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _uploadProof() async {
    if (widget.item.id == null) return;
    setState(() => _uploadingProof = true);
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('claims/${widget.item.id}_$_uid/proof.jpg');
      final bytes = await picked.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final String url = await ref.getDownloadURL();
      await ClaimService.attachProof(
        itemId: widget.item.id!,
        uid: _uid,
        proofUrl: url,
      );
      if (!mounted) return;
      setState(() => _proofUrl = url);
      _snack('Bukti serah terima berhasil diunggah.');
    } catch (e) {
      _snack('Gagal mengunggah bukti: $e');
    } finally {
      if (mounted) setState(() => _uploadingProof = false);
    }
  }

  Future<void> _confirmResolution() async {
    if (widget.item.id == null) return;
    setState(() => _resolving = true);
    try {
      if (widget.item.createdBy != null) {
        await ClaimService.resolveItem(widget.item.id!);
      }
      if (!mounted) return;
      setState(() => _resolved = true);
      _snack('Laporan ditandai selesai (Resolved).');
    } catch (e) {
      _snack('Gagal menyelesaikan laporan: $e');
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgScreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Klaim Barang',
          style: AppTextStyles.headingS17.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingStateView(message: 'Memuat status klaim...');
    }
    if (_error != null) {
      return ErrorStateView(message: _error!, onRetry: _loadClaim);
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s20),
      children: [
        _buildSummary(),
        const SizedBox(height: AppSpacing.s20),
        if (!_hasQuestions)
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: AppRadius.lgAll,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textWarning,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: Text(
                    'Laporan ini belum memiliki pertanyaan rahasia, sehingga '
                    'klaim tidak dapat diverifikasi.',
                    style: AppTextStyles.bodyS12.copyWith(
                      color: AppColors.textWarning,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (_claim?.status == ClaimStatus.approved)
          _buildApproved()
        else if (_claim?.isLocked ?? false)
          _buildRejected()
        else
          _buildQuestionForm(),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item.title, style: AppTextStyles.titleL16),
          const SizedBox(height: AppSpacing.s6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s6),
              Expanded(
                child: Text(
                  widget.item.location,
                  style: AppTextStyles.bodyM13.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionForm() {
    final int remaining = _claim?.remainingAttempts ?? ClaimService.maxAttempts;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s14),
            decoration: BoxDecoration(
              color: AppColors.bgAccentSoft,
              borderRadius: AppRadius.lgAll,
            ),
            child: Text(
              'Jawab pertanyaan rahasia untuk membuktikan kepemilikan. '
              'Sisa $remaining dari ${ClaimService.maxAttempts} percobaan.',
              style: AppTextStyles.bodyS12.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          ...List<Widget>.generate(widget.item.secretQuestions.length, (int i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ${widget.item.secretQuestions[i]}',
                    style: AppTextStyles.titleM14,
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  TextFormField(
                    controller: _answerControllers[i],
                    style: AppTextStyles.bodyM13,
                    decoration: const InputDecoration(
                      hintText: 'Jawabanmu',
                    ),
                    validator: (String? v) => (v == null || v.trim().isEmpty)
                        ? 'Jawaban wajib diisi'
                        : null,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.s8),
          _primaryButton(
            label: 'Kirim Jawaban',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildApproved() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusCard(
          icon: Icons.verified_rounded,
          color: AppColors.success,
          background: AppColors.successBg,
          title: 'Klaim Disetujui',
          message: 'Jawabanmu benar. Kamu dapat membuka chat dengan pemilik '
              'laporan untuk mengatur serah terima.',
        ),
        const SizedBox(height: AppSpacing.s16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.fullAll,
              ),
            ),
            icon: const Icon(Icons.chat_bubble_rounded, size: 18),
            label: Text(
              'Buka Chat',
              style: AppTextStyles.labelXl15.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s20),
        Text('Bukti Serah Terima (opsional)', style: AppTextStyles.titleM14),
        const SizedBox(height: AppSpacing.s8),
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                _proofUrl == null
                    ? Icons.upload_file_rounded
                    : Icons.check_circle_rounded,
                color: _proofUrl == null
                    ? AppColors.textMuted
                    : AppColors.success,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: Text(
                  _proofUrl == null
                      ? 'Belum ada bukti diunggah.'
                      : 'Bukti serah terima sudah diunggah.',
                  style: AppTextStyles.bodyS12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: _uploadingProof ? null : _uploadProof,
                child: _uploadingProof
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_proofUrl == null ? 'Unggah' : 'Ganti'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s20),
        if (_resolved)
          _statusCard(
            icon: Icons.task_alt_rounded,
            color: AppColors.success,
            background: AppColors.successBg,
            title: 'Laporan Selesai',
            message: 'Status laporan telah diperbarui menjadi Resolved.',
          )
        else
          _primaryButton(
            label: 'Konfirmasi Penyelesaian',
            loading: _resolving,
            onPressed: _confirmResolution,
          ),
      ],
    );
  }

  Widget _buildRejected() {
    return _statusCard(
      icon: Icons.lock_rounded,
      color: AppColors.error,
      background: AppColors.errorBg,
      title: 'Klaim Ditolak',
      message: 'Kamu telah gagal menjawab 3 kali. Klaim dikunci untuk akun ini '
          'pada laporan terkait (Limit Exceeded).',
    );
  }

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required Color background,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.xlAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleM14.copyWith(color: color),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  message,
                  style: AppTextStyles.bodyS12.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgInverse,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.labelXl15.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
