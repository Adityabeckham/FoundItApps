import 'package:flutter/material.dart';

/// Data satu laporan barang hilang atau ditemukan.
class ItemReport {
  const ItemReport({
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.imageAsset,
    required this.isLost,
    required this.thumbBackground,
    required this.category,
  });

  final String title;
  final String location;
  final String timeAgo;
  final String imageAsset;
  final bool isLost;
  final Color thumbBackground;
  final String category;
}

