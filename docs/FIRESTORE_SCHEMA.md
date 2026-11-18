# Skema Firestore FoundIt (MVP UTS)

## Koleksi

### `users`
| Field | Tipe | Keterangan |
|---|---|---|
| uid | string | ID pengguna (PK) |
| displayName | string | Nama tampilan |
| photoUrl | string? | URL foto profil |
| email | string? | Email |

### `items`
| Field | Tipe | Keterangan |
|---|---|---|
| id | string | ID laporan (auto-ID) |
| title | string | Nama barang |
| location | string | Nama lokasi |
| latitude | number? | Koordinat |
| longitude | number? | Koordinat |
| imageAsset / imageUrl | string | Foto barang |
| isLost | boolean | true = hilang, false = ditemukan |
| category | string | Kategori |
| status | string | Open / Waiting for Owner / Approved / Resolved |
| secretQuestions | array<string> | Pertanyaan rahasia (1-3, untuk Found) |
| secretAnswers | array<string> | Kunci jawaban pertanyaan rahasia (untuk verifikasi klaim) |
| reward | string? | Imbalan |
| timeAgo | string | Waktu relatif (display) |
| createdAt | timestamp | Waktu dibuat |
| createdBy | string | UID penemu/pelapor |

### `claims`
| Field | Tipe | Keterangan |
|---|---|---|
| id | string | ID klaim (`{itemId}_{claimerUid}`, unik per akun per laporan) |
| itemId | string | Referensi item |
| claimerUid | string | UID pengklaim |
| ownerUid | string? | UID penemu/pemilik laporan |
| answers | array<string> | Jawaban pertanyaan rahasia |
| attempts | number | Jumlah percobaan (max 3) |
| status | string | Pending / Approved / Rejected |
| rejectionReason | string? | Alasan penolakan (`Limit Exceeded`) |
| proofUrl | string? | Bukti serah terima |
| createdAt | timestamp | Waktu klaim pertama |
| updatedAt | timestamp | Waktu update terakhir |

### `chats`
| Field | Tipe | Keterangan |
|---|---|---|
| id | string | ID chat (`{itemId}_{claimerUid}`) |
| itemId | string | Referensi laporan |
| itemTitle | string | Judul laporan (untuk daftar chat) |
| ownerUid | string | UID pemilik/penemu laporan |
| claimerUid | string | UID pengklaim (approved) |
| participants | array<string> | [ownerUid, claimerUid] untuk query arrayContains |
| lastMessage | string | Ringkasan pesan terakhir |
| lastSenderUid | string? | Pengirim pesan terakhir |
| updatedAt | timestamp | Update terakhir (urut daftar chat) |

### `chats/{chatId}/messages`
| Field | Tipe | Keterangan |
|---|---|---|
| id | string | ID pesan (auto-ID) |
| chatId | string | ID chat |
| senderUid | string | UID pengirim |
| text | string | Isi pesan |
| createdAt | timestamp | Waktu kirim |

## Catatan
- Semua ID memakai Firestore auto-ID (tidak pakai uuid).
- Seed data: 10 item di 10 lokasi Kota Bandung (lihat `lib/data/dummy_reports.dart`).
- Status flow: Open → Waiting for Owner → Approved → Resolved; klaim gagal 3x → Rejected (Limit Exceeded).
