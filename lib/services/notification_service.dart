// Conditional export: implementasi native pada platform dengan dart:io
// (Android/iOS/desktop), stub no-op pada web.
export 'notification_service_web.dart'
    if (dart.library.io) 'notification_service_native.dart';
