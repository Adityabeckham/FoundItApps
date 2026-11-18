import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../data/dummy_reports.dart';
import '../data/firestore_collections.dart';
import '../models/item_report.dart';
import '../theme/app_colors.dart';

/// State katalog laporan barang (Provider + Firestore stream).
class ItemProvider extends ChangeNotifier {
  final List<ItemReport> _items = List<ItemReport>.of(dummyReports);
  String _query = '';
  String _filter = 'Semua';
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
  String get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ItemReport> get filteredItems {
    Iterable<ItemReport> result = _items;
    switch (_filter) {
      case 'Hilang':
        result = result.where((report) => report.isLost);
        break;
      case 'Ditemukan':
        result = result.where((report) => !report.isLost);
        break;
      case 'Semua':
        break;
      default:
        result = result.where((report) => report.category == _filter);
        break;
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
    return result.toList();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(String value) {
    _filter = value;
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
        if (snapshot.docs.isNotEmpty) {
          _items
            ..clear()
            ..addAll(snapshot.docs.map(_fromDoc));
        }
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

