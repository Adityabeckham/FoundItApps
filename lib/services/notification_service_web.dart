import 'dart:convert';

import '../models/item_report.dart';
import '../theme/app_colors.dart';

/// Stub notifikasi untuk platform web (flutter_local_notifications tidak
/// mendukung web). Semua panggilan menjadi no-op.
class NotificationService {
  NotificationService._();

  static void Function(String payload)? onSelectNotification;

  static Future<void> initialize() async {}

  static Future<void> showMatchNotification(
    ItemReport found, {
    ItemReport? lost,
  }) async {}

  static Future<void> showClaimNotification(ItemReport item) async {}

  static String? takeLaunchPayload() => null;

  static ItemReport? decodePayload(String payload) {
    try {
      final Map<String, dynamic> d =
          jsonDecode(payload) as Map<String, dynamic>;
      return ItemReport(
        id: d['id'] as String?,
        title: (d['title'] as String?) ?? 'Laporan',
        location: (d['location'] as String?) ?? '-',
        timeAgo: '',
        imageAsset: (d['imageAsset'] as String?) ??
            'assets/images/icon-apps.png',
        isLost: (d['isLost'] as bool?) ?? false,
        thumbBackground: AppColors.categoryBlueBg,
        category: (d['category'] as String?) ?? 'Lainnya',
        description: d['description'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
