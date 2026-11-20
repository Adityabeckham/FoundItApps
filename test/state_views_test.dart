import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foundit/screens/reports/detail_report_screen.dart';
import 'package:foundit/widgets/state_views.dart';

void main() {
  testWidgets('EmptyStateView menampilkan judul, pesan, dan aksi',
      (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyStateView(
            title: 'Belum ada laporan',
            message: 'Data masih kosong.',
            actionLabel: 'Reset Filter',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Belum ada laporan'), findsOneWidget);
    expect(find.text('Data masih kosong.'), findsOneWidget);

    await tester.tap(find.text('Reset Filter'));
    expect(tapped, isTrue);
  });

  testWidgets('LoadingStateView menampilkan indikator dan pesan',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingStateView(message: 'Memuat laporan...'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Memuat laporan...'), findsOneWidget);
  });

  testWidgets('ErrorStateView menampilkan pesan dan memicu retry',
      (WidgetTester tester) async {
    bool retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorStateView(
            message: 'Tidak dapat memuat data.',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Tidak dapat memuat data.'), findsOneWidget);

    await tester.tap(find.text('Coba Lagi'));
    expect(retried, isTrue);
  });

  testWidgets('Detail Laporan menampilkan empty state tanpa data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DetailReportScreen()),
    );

    expect(find.text('Laporan tidak ditemukan'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
  });
}
