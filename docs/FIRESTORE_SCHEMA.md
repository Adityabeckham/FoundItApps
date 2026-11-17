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
| reward | string? | Imbalan |
| timeAgo | string | Waktu relatif (display) |
| createdAt | timestamp | Waktu dibuat |
| createdBy | string | UID penemu/pelapor |

### `claims`
| Field | Tipe | Keterangan |
|---|---|---|
| id | string | ID klaim (auto-ID) |
| itemId | string | Referensi item |
| claimerUid | string | UID pengklaim |
| answers | array<string> | Jawaban pertanyaan rahasia |
| attempts | number | Jumlah percobaan (max 3) |
| status | string | Pending / Approved / Rejected |
| proofUrl | string? | Bukti serah terima |
| createdAt | timestamp | Waktu klaim |

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
