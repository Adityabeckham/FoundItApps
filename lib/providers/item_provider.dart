import 'package:flutter/material.dart';

import '../data/dummy_reports.dart';
import '../models/item_report.dart';

/// State katalog laporan barang (Provider).
class ItemProvider extends ChangeNotifier {
  final List<ItemReport> _items = List<ItemReport>.of(dummyReports);
  String _query = '';
  int _filterIndex = 0;

  List<ItemReport> get items => List<ItemReport>.unmodifiable(_items);
  String get query => _query;
  int get filterIndex => _filterIndex;

  List<ItemReport> get filteredItems {
    Iterable<ItemReport> result = _items;
    switch (_filterIndex) {
      case 1:
        result = result.where((report) => report.isLost);
        break;
      case 2:
        result = result.where((report) => !report.isLost);
        break;
      case 3:
        result = result.where((report) => report.category == 'Dompet');
        break;
      case 4:
        result = result.where((report) => report.category == 'Elektronik');
        break;
      case 5:
        result = result.where((report) => report.category == 'Kunci');
        break;
      default:
        break;
    }
    final String q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where(
        (report) =>
            report.title.toLowerCase().contains(q) ||
            report.location.toLowerCase().contains(q),
      );
    }
    return result.toList();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(int index) {
    _filterIndex = index;
    notifyListeners();
  }

  void addItem(ItemReport report) {
    _items.insert(0, report);
    notifyListeners();
  }
}
