import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:foundit/models/item_report.dart';
import 'package:foundit/theme/app_colors.dart';

/// Layanan notifikasi lokal FoundIt (flutter_local_notifications).
///
/// Tidak didukung pada web; semua panggilan menjadi no-op di web.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static String? _launchPayload;

  static const String _channelId = 'foundit_channel';
  static const String _channelName = 'FoundIt Notifikasi';
  static const String _channelDesc =
      'Notifikasi barang temuan yang cocok dan klaim baru';

  /// Callback saat notifikasi ditekan, membawa payload JSON.
  static void Function(String payload)? onSelectNotification;

  static Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onSelectNotification?.call(payload);
        }
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );
    await android?.requestNotificationsPermission();

    final NotificationAppLaunchDetails? launchDetails =
        await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = launchDetails?.notificationResponse?.payload;
    }

    _initialized = true;
  }

  /// Payload notifikasi yang membuka aplikasi saat terminated (sekali ambil).
  static String? takeLaunchPayload() {
    final String? payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

  /// Notifikasi saat ada barang temuan yang cocok dengan laporan kehilangan.
  static Future<void> showMatchNotification(
    ItemReport found, {
    ItemReport? lost,
  }) async {
    final String body = lost == null
        ? '"${found.title}" di ${found.location} mungkin barang yang kamu cari.'
        : '"${found.title}" di ${found.location} cocok dengan laporan '
            '"${lost.title}".';
    await _show(
      id: 1001,
      title: 'Barang temuan cocok!',
      body: body,
      payload: _encode(found),
    );
  }

  /// Notifikasi saat ada klaim baru pada laporan milik pengguna.
  static Future<void> showClaimNotification(ItemReport item) async {
    await _show(
      id: 1002,
      title: 'Klaim baru',
      body: 'Ada klaim baru untuk laporan "${item.title}".',
      payload: _encode(item),
    );
  }

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || !_initialized) return;
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android),
      payload: payload,
    );
  }

  static String _encode(ItemReport item) {
    return jsonEncode(<String, dynamic>{
      'id': item.id,
      'title': item.title,
      'location': item.location,
      'isLost': item.isLost,
      'category': item.category,
      'description': item.description,
    });
  }

  /// Rekonstruksi laporan dari payload notifikasi (untuk navigasi Detail).
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
