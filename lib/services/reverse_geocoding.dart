import 'dart:convert';

import 'package:http/http.dart' as http;

/// Ambil nama tempat (alamat) dari koordinat menggunakan Nominatim (OSM).
/// Mengembalikan `null` bila gagal atau tidak ada hasil.
Future<String?> reverseGeocode(double lat, double lng) async {
  final Uri uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
    'format': 'jsonv2',
    'lat': lat.toString(),
    'lon': lng.toString(),
    'accept-language': 'id',
    'zoom': '18',
  });

  try {
    final http.Response response = await http
        .get(uri, headers: const {'User-Agent': 'FoundIt/1.0 (UTS project)'})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;

    final dynamic json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) return null;

    final String? displayName = json['display_name'] as String?;
    if (displayName == null || displayName.trim().isEmpty) return null;

    return _shorten(displayName);
  } catch (_) {
    return null;
  }
}

/// Ambil komponen pertama & kedua dari display_name agar ringkas.
String _shorten(String displayName) {
  final List<String> parts = displayName
      .split(',')
      .map((String p) => p.trim())
      .where((String p) => p.isNotEmpty)
      .take(2)
      .toList();
  return parts.isEmpty ? displayName : parts.join(', ');
}
