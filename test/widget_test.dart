import 'package:flutter_test/flutter_test.dart';

import 'package:foundit/main.dart';

void main() {
  testWidgets('FoundIt app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FoundItApp());

    expect(find.text('FoundIt'), findsWidgets);
  });
}
