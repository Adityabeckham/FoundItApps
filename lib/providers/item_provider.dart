import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:foundit/data/dummy_reports.dart';
import 'package:foundit/data/firestore_collections.dart';
import 'package:foundit/models/item_report.dart';
import 'package:foundit/theme/app_colors.dart';

/// State katalog laporan barang (Provider + Firestore stream).
class ItemProvider extends ChangeNotifier {
  final List<ItemReport> _items = List<ItemReport>.of(dummyReports);
  String _query = '';
  String _statusFilter = 'Semua';
  String _categoryFilter = 'Semua';
  String _sortMode = 'Terbaru';
  double? _radiusKm;
  double? _userLat;
  double? _userLng;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  ItemProvider() {
    if (Firebase.apps.isNotEmpty) {
      listenToFirestore();
    }
  }

  List<ItemReport> get items => List<ItemReport>.unmodifiable(_items);
  String get query => _query;
  String get filter => _statusFilter != 'Semua' ? _statusFilter : _categoryFilter;
  String get statusFilter => _statusFilter;
  String get categoryFilter => _categoryFilter;
  String get sortMode => _sortMode;
  double? get radiusKm => _radiusKm;
  double? get userLat => _userLat;
  double? get userLng => _userLng;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ItemReport> get filteredItems {
    Iterable<ItemReport> result = _items;
    if (_statusFilter == 'Hilang') {
      result = result.where((report) => report.isLost);
    } else if (_statusFilter == 'Ditemukan') {
      result = result.where((report) => !report.isLost);
    }
    if (_categoryFilter != 'Semua') {
      result = result.where((report) => report.category == _categoryFilter);
    }
    final String q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where(
        (report) =>
            report.title.toLowerCase().contains(q) ||
            report.location.toLowerCase().contains(q) ||
            (report.description ?? '').toLowerCase().contains(q),
      );
    }

    // Filter radius (memerlukan lokasi user).
    if (_radiusKm != null && _userLat != null && _userLng != null) {
      result = result.where((report) {
        if (report.latitude == null || report.longitude == null) return false;
        return _distanceMeters(
              _userLat!,
              _userLng!,
              report.latitude!,
              report.longitude!,
            ) <=
            _radiusKm! * 1000;
      });
    }

    final List<ItemReport> list = result.toList();

    // Urutkan.
    switch (_sortMode) {
      case 'Terdekat':
        if (_userLat != null && _userLng != null) {
          list.sort((a, b) {
            final double da = _safeDistance(a);
            final double db = _safeDistance(b);
            return da.compareTo(db);
          });
        }
        break;
      case 'Imbalan tertinggi':
        list.sort((a, b) => _rewardValue(b).compareTo(_rewardValue(a)));
        break;
      case 'Terbaru':
      default:
        // Pertahankan urutan asli (remote desc createdAt, lalu seed).
        break;
    }

    return list;
  }

  double _distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    // Haversine sederhana.
    const double r = 6371000;
    final double dLat = _deg(lat2 - lat1);
    final double dLng = _deg(lng2 - lng1);
    final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_deg(lat1)) *
            math.cos(_deg(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2));
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _deg(double deg) => deg * (math.pi / 180);

  double _safeDistance(ItemReport r) {
    if (r.latitude == null || r.longitude == null) return double.infinity;
    if (_userLat == null || _userLng == null) return double.infinity;
    return _distanceMeters(_userLat!, _userLng!, r.latitude!, r.longitude!);
  }

  int _rewardValue(ItemReport r) {
    final String? reward = r.reward;
    if (reward == null) return 0;
    final String digits = reward.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(String value) {
    if (value == 'Hilang' || value == 'Ditemukan') {
      _statusFilter = value;
      _categoryFilter = 'Semua';
    } else if (value == 'Semua') {
      _statusFilter = 'Semua';
      _categoryFilter = 'Semua';
    } else {
      _categoryFilter = value;
      _statusFilter = 'Semua';
    }
    notifyListeners();
  }

  void setStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setCategoryFilter(String value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setSortMode(String value) {
    _sortMode = value;
    notifyListeners();
  }

  void setRadiusKm(double? value) {
    _radiusKm = value;
    notifyListeners();
  }

  void setUserLocation(double? lat, double? lng) {
    _userLat = lat;
    _userLng = lng;
    notifyListeners();
  }

  void addItem(ItemReport report) {
    _items.insert(0, report);
    notifyListeners();
  }

  /// Dengarkan stream Firestore `items`. Fallback ke dummy jika kosong/error.
  void listenToFirestore() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription = FirebaseFirestore.instance
        .collection(FirestoreCollections.items)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _isLoading = false;
        _error = null;
        final List<ItemReport> remote =
            snapshot.docs.map(_fromDoc).toList();
        final Set<String?> remoteIds =
            remote.map((ItemReport r) => r.id).toSet();
        final List<ItemReport> seed = dummyReports
            .where((ItemReport r) => !remoteIds.contains(r.id))
            .toList();
        _items
          ..clear()
          ..addAll(<ItemReport>[...remote, ...seed]);
        notifyListeners();
      },
      onError: (Object _) {
        _isLoading = false;
        _error =
            'Tidak dapat memuat data. Periksa koneksi internet Anda lalu coba lagi.';
        notifyListeners();
      },
    );
  }

  /// Coba muat ulang data dari Firestore.
  void retry() {
    if (Firebase.apps.isEmpty) {
      _error = null;
      notifyListeners();
      return;
    }
    listenToFirestore();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  static ItemReport _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> d = doc.data() ?? <String, dynamic>{};
    return ItemReport(
      id: doc.id,
      title: (d['title'] as String?) ?? 'Tanpa judul',
      location: (d['location'] as String?) ?? '-',
      timeAgo: (d['timeAgo'] as String?) ?? '',
      imageAsset: (d['imageAsset'] as String?) ??
          (d['imageUrl'] as String?) ??
          'assets/images/icon-apps.png',
      isLost: (d['isLost'] as bool?) ?? true,
      thumbBackground: AppColors.categoryBlueBg,
      category: (d['category'] as String?) ?? 'Lainnya',
      description: d['description'] as String?,
      status: (d['status'] as String?) ?? ReportStatus.open,
      secretQuestions: (d['secretQuestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      secretAnswers: (d['secretAnswers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      latitude: (d['latitude'] as num?)?.toDouble(),
      longitude: (d['longitude'] as num?)?.toDouble(),
      reward: d['reward'] as String?,
      createdBy: d['createdBy'] as String?,
    );
  }
}

