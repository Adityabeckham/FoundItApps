import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:foundit/data/firestore_collections.dart';
import 'package:foundit/models/item_report.dart';

/// Logika klaim barang: verifikasi jawaban rahasia (maks. 3 percobaan),
/// penyimpanan bukti serah terima, dan penyelesaian laporan.
class ClaimService {
  ClaimService._();

  static const int maxAttempts = 3;

  static DocumentReference<Map<String, dynamic>> claimRef(
    String itemId,
    String uid,
  ) {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.claims)
        .doc('${itemId}_$uid');
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> claimStream(
    String itemId,
    String uid,
  ) {
    return claimRef(itemId, uid).snapshots();
  }

  /// Bandingkan jawaban (trim + case-insensitive).
  static bool answersCorrect(List<String> expected, List<String> given) {
    if (expected.isEmpty || expected.length != given.length) return false;
    for (int i = 0; i < expected.length; i++) {
      if (_normalize(expected[i]) != _normalize(given[i])) return false;
    }
    return true;
  }

  static String _normalize(String value) => value.trim().toLowerCase();

  /// Kirim jawaban klaim lalu kembalikan status terbaru.
  static Future<Claim> submitClaim({
    required ItemReport item,
    required List<String> answers,
    required String uid,
    required int currentAttempts,
  }) async {
    final String itemId = item.id!;
    final bool correct = answersCorrect(item.secretAnswers, answers);
    final int attempts = currentAttempts + 1;

    String status = ClaimStatus.pending;
    String? reason;
    if (correct) {
      status = ClaimStatus.approved;
    } else if (attempts >= maxAttempts) {
      status = ClaimStatus.rejected;
      reason = 'Limit Exceeded';
    }

    await claimRef(itemId, uid).set(<String, dynamic>{
      'itemId': itemId,
      'claimerUid': uid,
      'ownerUid': item.createdBy,
      'answers': answers,
      'attempts': attempts,
      'status': status,
      'rejectionReason': reason,
      if (currentAttempts == 0) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return Claim(
      id: '${itemId}_$uid',
      itemId: itemId,
      claimerUid: uid,
      answers: answers,
      attempts: attempts,
      status: status,
      rejectionReason: reason,
    );
  }

  static Future<void> attachProof({
    required String itemId,
    required String uid,
    required String proofUrl,
  }) async {
    await claimRef(itemId, uid).set(<String, dynamic>{
      'proofUrl': proofUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Tandai laporan selesai setelah serah terima dikonfirmasi.
  static Future<void> resolveItem(String itemId) async {
    await FirebaseFirestore.instance
        .collection(FirestoreCollections.items)
        .doc(itemId)
        .set(<String, dynamic>{
      'status': ReportStatus.resolved,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream klaim milik pengguna (untuk hitung jumlah klaim disetujui).
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      claimsForUser(String uid) {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.claims)
        .where('claimerUid', isEqualTo: uid)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs,
        );
  }
}
