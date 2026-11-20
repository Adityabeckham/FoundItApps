import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Unggah gambar ke Cloudinary (unsigned upload) tanpa Firebase Storage.
/// Mengembalikan URL `secure_url` yang bisa dipakai `Image.network`.
class ImageUploadService {
  ImageUploadService._();

  static const String _cloudName = 'xauw8s47';
  static const String _uploadPreset = 'laporan';

  static Future<String> upload(XFile file) async {
    final Uri uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );
    final bytes = await file.readAsBytes();
    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name.isEmpty ? 'upload.jpg' : file.name,
        ),
      );

    final http.StreamedResponse streamed = await request.send();
    final http.Response response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Upload gambar gagal (${response.statusCode}).');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final String? url = data['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('URL gambar tidak ditemukan pada respons.');
    }
    return url;
  }
}
