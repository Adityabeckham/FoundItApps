import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:foundit/data/firestore_collections.dart';
import 'package:foundit/models/item_report.dart';
import 'package:foundit/services/image_upload_service.dart';
import 'package:foundit/services/reverse_geocoding.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/widgets/top_banner.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/utils/app_transitions.dart';
import 'package:foundit/widgets/map_preview.dart';
import 'package:foundit/screens/reports/location_picker_screen.dart';

/// Form laporan barang hilang/ditemukan.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = <XFile>[];
  bool _isLost = true;
  String _category = 'Dompet';
  double? _latitude;
  double? _longitude;
  bool _submitting = false;

  final List<TextEditingController> _questionControllers =
      <TextEditingController>[TextEditingController()];
  final List<TextEditingController> _answerControllers =
      <TextEditingController>[TextEditingController()];

  static const List<String> _categories = <String>[
    'Dompet',
    'Kunci',
    'Elektronik',
    'Tas',
    'Aksesoris',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _rewardController.dispose();
    for (final TextEditingController c in _questionControllers) {
      c.dispose();
    }
    for (final TextEditingController c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (_photos.length >= 3) {
      TopBanner.info(context, 'Maksimal 3 foto',
          message: 'Hapus salah satu foto untuk menambah yang baru.');
      return;
    }
    final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      for (final XFile f in picked) {
        if (_photos.length < 3) _photos.add(f);
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          TopBanner.error(context, 'Izin lokasi ditolak',
              message: 'Aktifkan izin lokasi untuk memakai fitur ini.');
        }
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
      }
      final String? place = await reverseGeocode(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _locationController.text = place ??
            'Lat ${pos.latitude.toStringAsFixed(5)}, '
                'Lng ${pos.longitude.toStringAsFixed(5)}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
        );
      }
    }
  }

  Future<void> _openMapPicker() async {
    final SelectedLocation? result = await pushSlide<SelectedLocation>(
      context,
      LocationPickerScreen(
        initial: (_latitude != null && _longitude != null)
            ? LatLng(_latitude!, _longitude!)
            : null,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _locationController.text = result.address;
    });
  }

  void _addQuestion() {
    if (_questionControllers.length >= 3) return;
    setState(() {
      _questionControllers.add(TextEditingController());
      _answerControllers.add(TextEditingController());
    });
  }

  void _removeQuestion(int index) {
    if (_questionControllers.length <= 1) return;
    setState(() {
      _questionControllers[index].dispose();
      _questionControllers.removeAt(index);
      _answerControllers[index].dispose();
      _answerControllers.removeAt(index);
    });
  }

  Future<List<String>> _uploadPhotos(String itemId) async {
    final List<String> urls = <String>[];
    for (final XFile photo in _photos) {
      urls.add(await ImageUploadService.upload(photo));
    }
    return urls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photos.isEmpty) {
      TopBanner.error(context, 'Foto wajib', message: 'Unggah minimal 1 foto barang.');
      return;
    }
    if (!_isLost) {
      bool hasQuestion = false;
      for (int i = 0; i < _questionControllers.length; i++) {
        final bool questionFilled =
            _questionControllers[i].text.trim().isNotEmpty;
        final bool answerFilled = _answerControllers[i].text.trim().isNotEmpty;
        if (questionFilled) hasQuestion = true;
        if (questionFilled != answerFilled) {
          TopBanner.error(
            context,
            'Pertanyaan tidak lengkap',
            message: 'Isi pertanyaan beserta jawaban rahasianya.',
          );
          return;
        }
      }
      if (!hasQuestion) {
        TopBanner.error(
          context,
          'Pertanyaan wajib',
          message: 'Buat minimal 1 pertanyaan rahasia.',
        );
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
      final DocumentReference<Map<String, dynamic>> docRef =
          FirebaseFirestore.instance.collection(FirestoreCollections.items).doc();
      final List<String> urls = await _uploadPhotos(docRef.id);
      final List<String> questions = <String>[];
      final List<String> answers = <String>[];
      if (!_isLost) {
        for (int i = 0; i < _questionControllers.length; i++) {
          final String q = _questionControllers[i].text.trim();
          if (q.isEmpty) continue;
          questions.add(q);
          answers.add(_answerControllers[i].text.trim());
        }
      }

      await docRef.set(<String, dynamic>{
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'imageAsset': urls.isNotEmpty ? urls.first : null,
        'imageUrl': urls.isNotEmpty ? urls.first : null,
        'isLost': _isLost,
        'category': _category,
        'status': ReportStatus.open,
        'secretQuestions': questions,
        'secretAnswers': answers,
        'reward': _rewardController.text.trim().isEmpty
            ? null
            : _rewardController.text.trim(),
        'timeAgo': 'Baru saja',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
        'description': _descController.text.trim(),
      });

      if (!mounted) return;
      TopBanner.success(context, 'Laporan tersimpan',
          message: 'Laporan berhasil disimpan.');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        TopBanner.error(context, 'Gagal menyimpan', message: '$e');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(title: const Text('Lapor Barang')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.s20),
            children: [
              // Tipe laporan
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLost = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _isLost ? AppColors.bgInverse : null,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              'Hilang',
                              style: AppTextStyles.labelM12Semi.copyWith(
                                color: _isLost
                                    ? AppColors.textOnBrand
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLost = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: !_isLost ? AppColors.bgInverse : null,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              'Ditemukan',
                              style: AppTextStyles.labelM12Semi.copyWith(
                                color: !_isLost
                                    ? AppColors.textOnBrand
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              // Foto
              GestureDetector(
                onTap: _pickPhotos,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: AppRadius.xlAll,
                    border: Border.all(
                      color: AppColors.borderBrand,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _photos.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 32,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              'Unggah foto barang (maks. 3)',
                              style: AppTextStyles.labelM12.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          itemCount: _photos.length,
                          itemBuilder: (context, index) => Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.s8),
                            child: ClipRRect(
                              borderRadius: AppRadius.lgAll,
                              child: Image.file(
                                File(_photos[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.bgSubtle,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              // Nama barang
              _fieldLabel('Nama barang'),
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.bodyM13,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Kunci motor Honda',
                ),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              // Kategori
              _fieldLabel('Kategori'),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(),
                items: _categories
                    .map(
                      (String c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c, style: AppTextStyles.bodyM13),
                      ),
                    )
                    .toList(),
                onChanged: (String? v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              // Ciri khusus
              _fieldLabel('Ciri khusus'),
              TextFormField(
                controller: _descController,
                style: AppTextStyles.bodyM13,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi ciri khusus barang...',
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              // Lokasi
              _fieldLabel('Lokasi'),
              TextFormField(
                controller: _locationController,
                style: AppTextStyles.bodyM13,
                decoration: InputDecoration(
                  hintText: 'Nama lokasi / alamat',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location_rounded),
                    onPressed: _useCurrentLocation,
                    tooltip: 'Gunakan lokasi saya',
                  ),
                ),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.s8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text('Pilih Lokasi di Peta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.borderBrand),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                ),
              ),
              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: AppSpacing.s12),
                MapPreview(
                  key: ValueKey<String>('$_latitude,$_longitude'),
                  latitude: _latitude!,
                  longitude: _longitude!,
                ),
              ],
              const SizedBox(height: AppSpacing.s16),
              // Imbalan
              _fieldLabel('Imbalan (opsional)'),
              TextFormField(
                controller: _rewardController,
                style: AppTextStyles.bodyM13,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Rp 100.000',
                ),
              ),
              // Pertanyaan rahasia (hanya Ditemukan)
              if (!_isLost) ...[
                const SizedBox(height: AppSpacing.s20),
                Row(
                  children: [
                    Text('Pertanyaan Rahasia', style: AppTextStyles.titleM14),
                    const Spacer(),
                    if (_questionControllers.length < 3)
                      TextButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: Text(
                          'Tambah',
                          style: AppTextStyles.labelM12.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                ...List<Widget>.generate(_questionControllers.length, (int i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextField(
                                controller: _questionControllers[i],
                                style: AppTextStyles.bodyM13,
                                decoration: InputDecoration(
                                  hintText: 'Pertanyaan ${i + 1}',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s8),
                              TextField(
                                controller: _answerControllers[i],
                                style: AppTextStyles.bodyM13,
                                decoration: InputDecoration(
                                  hintText: 'Jawaban benar ${i + 1}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_questionControllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: AppColors.error,
                            ),
                            onPressed: () => _removeQuestion(i),
                          ),
                      ],
                    ),
                  );
                }),
                Text(
                  'Minimal 1 pertanyaan beserta jawabannya (maks. 3).',
                  style: AppTextStyles.caption10,
                ),
              ],
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgInverse,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Kirim Laporan',
                          style: AppTextStyles.labelXl15.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s6),
      child: Text(text, style: AppTextStyles.titleM14),
    );
  }
}



