import 'package:flutter_test/flutter_test.dart';

import 'package:foundit/services/notifications/notification_service.dart';

void main() {
  test('decodePayload merekonstruksi laporan dari payload', () {
    final item = NotificationService.decodePayload(
      '{"id":"item_04","title":"Tas Ransel Hitam","location":"Paris Van Java",'
      '"isLost":false,"category":"Tas","description":"Tas hitam"}',
    );

    expect(item, isNotNull);
    expect(item!.id, 'item_04');
    expect(item.title, 'Tas Ransel Hitam');
    expect(item.location, 'Paris Van Java');
    expect(item.isLost, isFalse);
    expect(item.category, 'Tas');
    expect(item.description, 'Tas hitam');
  });

  test('decodePayload mengembalikan null untuk payload tidak valid', () {
    expect(NotificationService.decodePayload('bukan-json'), isNull);
  });
}
