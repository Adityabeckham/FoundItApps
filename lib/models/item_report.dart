import 'package:flutter/material.dart';

/// Status laporan barang.
class ReportStatus {
  static const String open = 'Open';
  static const String waitingForOwner = 'Waiting for Owner';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
  static const String resolved = 'Resolved';
}

/// Status klaim barang.
class ClaimStatus {
  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
}

/// Data satu laporan barang hilang atau ditemukan.
class ItemReport {
  const ItemReport({
    this.id,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.imageAsset,
    required this.isLost,
    required this.thumbBackground,
    required this.category,
    this.description,
    this.status = ReportStatus.open,
    this.secretQuestions = const <String>[],
    this.latitude,
    this.longitude,
    this.reward,
    this.createdAt,
    this.createdBy,
  });

  final String? id;
  final String title;
  final String location;
  final String timeAgo;
  final String imageAsset;
  final bool isLost;
  final Color thumbBackground;
  final String category;
  final String? description;
  final String status;
  final List<String> secretQuestions;
  final double? latitude;
  final double? longitude;
  final String? reward;
  final DateTime? createdAt;
  final String? createdBy;
}

/// Data pengguna terautentikasi.
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.email,
  });

  final String uid;
  final String displayName;
  final String? photoUrl;
  final String? email;
}

/// Data klaim barang (jawaban pertanyaan rahasia, max 3 percobaan).
class Claim {
  const Claim({
    this.id,
    required this.itemId,
    required this.claimerUid,
    this.answers = const <String>[],
    this.attempts = 0,
    this.status = ClaimStatus.pending,
    this.proofUrl,
    this.createdAt,
  });

  final String? id;
  final String itemId;
  final String claimerUid;
  final List<String> answers;
  final int attempts;
  final String status;
  final String? proofUrl;
  final DateTime? createdAt;

  bool get isLocked => attempts >= 3 && status != ClaimStatus.approved;
}

/// Pesan chat privat antar pengguna setelah klaim disetujui.
class ChatMessage {
  const ChatMessage({
    this.id,
    required this.chatId,
    required this.senderUid,
    required this.text,
    this.createdAt,
  });

  final String? id;
  final String chatId;
  final String senderUid;
  final String text;
  final DateTime? createdAt;
}
