import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:foundit/data/firestore_collections.dart';
import 'package:foundit/models/item_report.dart';

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

  /// Stream pesan real-time (urut terlama Ã¢â€ â€™ terbaru).
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
              imageUrl: d['imageUrl'] as String?,
              createdAt: ts?.toDate(),
            );
          }).toList(),
        );
  }

  /// Kirim pesan dan perbarui ringkasan chat.
  static Future<void> sendMessage({
    required String chatId,
    required String senderUid,
    String text = '',
    String? imageUrl,
  }) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty && (imageUrl == null || imageUrl.isEmpty)) return;
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    final DocumentReference<Map<String, dynamic>> msgRef =
        _messages(chatId).doc();
    batch.set(msgRef, <String, dynamic>{
      'senderUid': senderUid,
      'text': trimmed,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      chatRef(chatId),
      <String, dynamic>{
        'lastMessage': trimmed.isEmpty ? 'Ã°Å¸â€œÂ· Foto' : trimmed,
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

  /// Ambil profil pengguna (nama + foto) dari koleksi `users`.
  static Future<({String name, String? photoUrl})> userProfile(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      final Map<String, dynamic>? data = doc.data();
      final String? name = data?['displayName'] as String?;
      final String? photo = data?['photoUrl'] as String?;
      if (name != null && name.trim().isNotEmpty) {
        return (name: name, photoUrl: photo);
      }
    } catch (_) {
      // abaikan, coba fallback Auth di bawah
    }
    // Fallback ke Firebase Auth bila uid adalah pengguna saat ini.
    try {
      final User? u = FirebaseAuth.instance.currentUser;
      if (u != null && u.uid == uid) {
        final String? name = u.displayName;
        if (name != null && name.trim().isNotEmpty) {
          return (name: name, photoUrl: u.photoURL);
        }
      }
    } catch (_) {
      // abaikan
    }
    return (name: 'Pengguna', photoUrl: null);
  }

  /// Ambil nama tampilan pengguna (kompatibilitas).
  static Future<String> displayName(String uid) async {
    final profile = await userProfile(uid);
    return profile.name;
  }
}
