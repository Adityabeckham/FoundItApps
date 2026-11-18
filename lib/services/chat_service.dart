import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/firestore_collections.dart';
import '../models/item_report.dart';

/// Layanan chat privat berbasis Firestore (real-time via snapshots()).
class ChatService {
  ChatService._();

  /// ID chat deterministik: satu ruang per laporan per pengklaim.
  static String chatId(String itemId, String claimerUid) =>
      '${itemId}_$claimerUid';

  static DocumentReference<Map<String, dynamic>> chatRef(String id) {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.chats)
        .doc(id);
  }

  static CollectionReference<Map<String, dynamic>> _messages(String id) {
    return chatRef(id).collection(FirestoreCollections.messages);
  }

  /// Pastikan dokumen chat ada (idempotent, tidak menimpa data lama).
  static Future<void> ensureChat({
    required String itemId,
    required String itemTitle,
    required String ownerUid,
    required String claimerUid,
  }) async {
    final String id = chatId(itemId, claimerUid);
    final DocumentSnapshot<Map<String, dynamic>> existing =
        await chatRef(id).get();
    if (existing.exists) return;
    await chatRef(id).set(<String, dynamic>{
      'itemId': itemId,
      'itemTitle': itemTitle,
      'ownerUid': ownerUid,
      'claimerUid': claimerUid,
      'participants': <String>[ownerUid, claimerUid],
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream pesan real-time (urut terlama → terbaru).
  static Stream<List<ChatMessage>> messagesStream(String id) {
    return _messages(id)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> d = doc.data() ?? <String, dynamic>{};
            final Timestamp? ts = d['createdAt'] as Timestamp?;
            return ChatMessage(
              id: doc.id,
              chatId: id,
              senderUid: (d['senderUid'] as String?) ?? '',
              text: (d['text'] as String?) ?? '',
              createdAt: ts?.toDate(),
            );
          }).toList(),
        );
  }

  /// Kirim pesan dan perbarui ringkasan chat.
  static Future<void> sendMessage({
    required String chatId,
    required String senderUid,
    required String text,
  }) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    final DocumentReference<Map<String, dynamic>> msgRef =
        _messages(chatId).doc();
    batch.set(msgRef, <String, dynamic>{
      'senderUid': senderUid,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      chatRef(chatId),
      <String, dynamic>{
        'lastMessage': trimmed,
        'lastSenderUid': senderUid,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  /// Daftar chat milik pengguna (disortir di sisi klien agar tanpa index).
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      chatsForUser(String uid) {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.chats)
        .where('participants', arrayContains: uid)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snapshot.docs.toList();
            docs.sort((a, b) {
              final Timestamp? ta = a.data()['updatedAt'] as Timestamp?;
              final Timestamp? tb = b.data()['updatedAt'] as Timestamp?;
              final int va = ta?.millisecondsSinceEpoch ?? 0;
              final int vb = tb?.millisecondsSinceEpoch ?? 0;
              return vb.compareTo(va);
            });
            return docs;
          },
        );
  }

  /// Ambil nama tampilan pengguna.
  static Future<String> displayName(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      final String? name = doc.data()?['displayName'] as String?;
      if (name != null && name.trim().isNotEmpty) return name;
    } catch (_) {
      // abaikan, gunakan fallback
    }
    return 'Pengguna';
  }
}
