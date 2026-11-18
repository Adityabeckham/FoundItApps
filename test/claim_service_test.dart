import 'package:flutter_test/flutter_test.dart';

import 'package:foundit/models/item_report.dart';
import 'package:foundit/services/claim_service.dart';

void main() {
  group('ClaimService.answersCorrect', () {
    test('benar bila semua jawaban cocok (trim + case-insensitive)', () {
      expect(
        ClaimService.answersCorrect(
          <String>['Cokelat', 'Dua'],
          <String>[' cokelat ', 'dua'],
        ),
        isTrue,
      );
    });

    test('salah bila ada jawaban tidak cocok', () {
      expect(
        ClaimService.answersCorrect(<String>['Cokelat'], <String>['Hitam']),
        isFalse,
      );
    });

    test('salah bila jumlah jawaban berbeda', () {
      expect(
        ClaimService.answersCorrect(
          <String>['Cokelat', 'Dua'],
          <String>['Cokelat'],
        ),
        isFalse,
      );
    });

    test('salah bila kunci jawaban kosong', () {
      expect(
        ClaimService.answersCorrect(const <String>[], <String>['apa saja']),
        isFalse,
      );
    });
  });

  group('Claim', () {
    test('terkunci setelah 3 percobaan gagal', () {
      const Claim claim = Claim(
        itemId: 'item_01',
        claimerUid: 'uid',
        attempts: 3,
        status: ClaimStatus.rejected,
        rejectionReason: 'Limit Exceeded',
      );
      expect(claim.isLocked, isTrue);
      expect(claim.remainingAttempts, 0);
    });

    test('tidak terkunci bila klaim disetujui', () {
      const Claim claim = Claim(
        itemId: 'item_01',
        claimerUid: 'uid',
        attempts: 3,
        status: ClaimStatus.approved,
      );
      expect(claim.isLocked, isFalse);
    });

    test('sisa percobaan berkurang sesuai attempt', () {
      const Claim claim = Claim(
        itemId: 'item_01',
        claimerUid: 'uid',
        attempts: 1,
      );
      expect(claim.remainingAttempts, 2);
    });
  });
}
