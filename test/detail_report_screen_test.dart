import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foundit/models/item_report.dart';
import 'package:foundit/screens/reports/detail_report_screen.dart';

void main() {
  const ItemReport item = ItemReport(
    id: 'test_01',
    title: 'Dompet Kulit Cokelat',
    location: 'Kampus ITB',
    timeAgo: '5 jam lalu',
    imageAsset: 'assets/images/icon-apps.png',
    isLost: true,
    thumbBackground: Color(0xFFFFFFFF),
    category: 'Dompet',
    description: 'Dompet kulit cokelat berisi KTP.',
    status: ReportStatus.open,
  );

  Widget buildApp() {
    return MaterialApp(
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/detail') {
          return MaterialPageRoute<void>(
            builder: (_) => DetailReportScreen(
              report: settings.arguments as ItemReport?,
            ),
          );
        }
        return MaterialPageRoute<void>(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: item,
                ),
                child: const Text('Buka Detail'),
              ),
            ),
          ),
        );
      },
    );
  }

  testWidgets('menampilkan data laporan dari route arguments',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Buka Detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Laporan'), findsOneWidget);
    expect(find.text('Dompet Kulit Cokelat'), findsOneWidget);
    expect(find.text('Kampus ITB'), findsOneWidget);
    expect(find.text('Deskripsi Barang'), findsOneWidget);
    expect(find.text('Dompet kulit cokelat berisi KTP.'), findsOneWidget);
    expect(find.text('Hilang'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Dompet'), findsOneWidget);
  });

  testWidgets('tombol back kembali ke halaman sebelumnya',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Buka Detail'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Laporan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Buka Detail'), findsOneWidget);
    expect(find.text('Detail Laporan'), findsNothing);
  });
}
