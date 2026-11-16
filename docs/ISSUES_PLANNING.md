# FoundIt — Task Planning (UTS Pemrograman Mobile II)

**Repo:** foundit (Flutter/Dart) · **Tim:** 2 orang (Aditya + Alpin) · **Tenggat:** 2 minggu (take-home UTS)
**Design Aplikasi di Figma:** https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171
**Docs:** `docs/FoundIt-Project.md`, `docs/UTS TIF Ganjil 2026-2027 TIF RP 24B CID.md`

> Petunjuk: buat issue GitHub dari setiap item di bawah (judul + assignee + label + milestone + acceptance criteria). Assignee disarankan; boleh disesuaikan beban tim.

## Status Saat Ini (Sudah Selesai)

- [x] Struktur project, theme/design system, assets & font
- [x] Onboarding 1, Onboarding 2, Login (UI)
- [x] Dashboard katalog (UI + dummy data + filter chips)
- [x] Animasi transisi slide+fade
- [x] README, metadata Android/web, smoke test

## Sisa Pekerjaan (9 Fitur MVP UTS)

### Milestone M0 — Setup & Infra (Hari 1–2)

**Issue #1 — Setup Firebase project & konfigurasi FlutterFire**

- Assignee: Anda
- Label: `setup`, `backend`
- Acceptance Criteria:
  - Project Firebase (Spark/Free) dibuat; `google-services.json` di `android/app/`
  - `flutterfire configure` dijalankan, `firebase_core` terdaftar
  - `Firebase.initializeApp()` dipanggil di `main()` tanpa error
  - Aplikasi tetap `flutter analyze` & `flutter test` lulus

**Issue #2 — Tambah dependency MVP (Firebase, map, notifikasi, picker)**

- Assignee: Anda
- Label: `setup`, `dependencies`
- Catatan: bertentangan dengan batasan "no new deps" tahap sebelumnya; ini keputusan tim (MVP butuh Firebase dsb). Gunakan hanya paket free-tier.
- Paket: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `flutter_map`, `geolocator`, `flutter_local_notifications`, `image_picker`, `uuid`, `provider`, `intl`
- Acceptance Criteria:
  - `pubspec.yaml` valid, `flutter pub get` sukses
  - Tidak ada dependency berbayar

**Issue #3 — Seed data & model Firestore schema**

- Assignee: Alpin
- Label: `data`, `backend`
- Acceptance Criteria:
  - Model `ItemReport` + `User` + `Claim` + `ChatMessage` dengan null-safety
  - Dokumen Firestore: `items`, `users`, `claims`, `chats/{id}/messages`
  - Seed 10 barang & 10 lokasi Kota Bandung (data dummy lokal dulu)

### Milestone M1 — Autentikasi (Hari 2–4)

**Issue #4 — Google Sign-In (Firebase Auth)**

- Assignee: Anda
- Label: `feature`, `auth`
- Acceptance Criteria:
  - Tombol "Sign in with Google" login sukses ke Firebase
  - Session persist (auto-login saat app dibuka ulang)
  - Tombol "Sign in with Apple" boleh placeholder/disabled dengan tooltip (Apple butuh akun dev berbayar)
  - Error handling (user cancel, network) tampil SnackBar
  - Setelah login → navigate ke Dashboard, bukan bisa back ke Login

**Issue #5 — Profil Dasar (edit nama/foto + logout)**

- Assignee: Alpin
- Label: `feature`, `profile`
- Acceptance Criteria:
  - Halaman Profil menampilkan nama & foto user (dari Auth)
  - Edit nama & foto (image_picker → Firebase Storage) tersimpan
  - Logout → kembali ke Login, state dibersihkan
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171
  - Struktur Full Code UI Flutter: SlicingUi.md

### Milestone M2 — Data & Laporan (Hari 4–8)

**Issue #6 — Form Laporan Barang (Lost/Found)**

- Assignee: Alpin
- Label: `feature`, `form`
- Acceptance Criteria:
  - Form: nama barang, kategori, ciri khusus, foto (kamera/galeri), lokasi (map picker), imbalan/reward
  - Untuk "Found": buat 1–3 pertanyaan rahasia (validasi min 1)
  - Validasi field wajib (nama, kategori, lokasi, foto,waktu jam tgl,bulan,tahun)
  - Submit → dokumen tersimpan di Firestore `items` dengan status `Open`
  - Loading state & success SnackBar
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171
  - Struktur Full Code UI Flutter: SlicingUi.md

  **Issue #7 — Dashboard Katalog terhubung Firestore + Detail Laporan**

- Assignee: Anda
- Label: `feature`, `dashboard`
- Acceptance Criteria:
  - Stream `items` (orderBy createdAt desc) tampil real-time
  - Tap kartu → halaman Detail Laporan (foto, deskripsi, lokasi, status, tombol Klaim)
  - Empty state & loading spinner
  - Search bar & filter chips memfilter list

**Issue #8 — Pencarian & Filter (keyword + kategori)**

- Assignee: Alpin
- Label: `feature`, `search`
- Acceptance Criteria:
  - Search by nama/ciri khusus (case-insensitive)
  - Filter kategori: Semua/Hilang/Ditemukan/Dompet/Elektronik/Kunci/dll
  - Kombinasi search + filter bekerja
  - Hasil update tanpa restart app
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171
  - Struktur Full Code UI Flutter: SlicingUi.md

### Milestone M3 — Peta (Hari 8–10)

**Issue #9 — Peta Radius OpenStreetMap ("Lost Around Me")**

- Assignee: Anda
- Label: `feature`, `map`
- Acceptance Criteria:
  - `flutter_map` + OSM tile, pin untuk setiap laporan (warna berbeda lost/found)
  - Minta izin lokasi (geolocator), tampilkan posisi user
  - Filter radius (mis. 1/3/5 km) & daftar laporan terdekat
  - Tap pin → bottom sheet detail singkat + link ke Detail Laporan
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171
  - Struktur Full Code UI Flutter: SlicingUi.md

  **Issue #10 — Location picker di Form Laporan**

- Assignee: Alpin
- Label: `feature`, `map`
- Acceptance Criteria:
  - Pilih lokasi via tap pada peta atau "lokasi saya sekarang"
  - Koordinat (lat,lng) + nama tempat tersimpan di item
  - Preview peta kecil di form
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171

### Milestone M4 — Klaim & Chat (Hari 10–12)

**Issue #11 — Klaim Barang + Verifikasi Rahasia (maks. 3x)**

- Assignee: Anda
- Label: `feature`, `claim`
- Acceptance Criteria:
  - Tombol "Klaim" di Detail (hanya untuk item Found milik orang lain)
  - Jawab 1–3 pertanyaan rahasia; hitung percobaan (max 3)
  - Benar → status klaim Approved, buka chat
  - Salah 3x → klaim Rejected (Limit Exceeded), tombol terkunci untuk akun itu
  - Upload bukti serah terima (opsional) → status Resolved
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171

**Issue #12 — In-App Chat Privat (Firestore)**

- Assignee: Alpin
- Label: `feature`, `chat`
- Acceptance Criteria:
  - Chat terbuka otomatis setelah klaim Approved
  - Real-time via Firestore `snapshots()`
  - Tampil nama lawan bicara, timestamp, bubble kiri/kanan
  - Input + send, scroll ke bawah otomatis
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171

### Milestone M5 — Notifikasi (Hari 12–13)

**Issue #13 — Notifikasi Lokal**

- Assignee: Alpin
- Label: `feature`, `notifications`
- Acceptance Criteria:
  - `flutter_local_notifications` terkonfigurasi (Android channel)
  - Notif saat ada barang temuan yang cocok / klaim masuk (simulasi dari data lokal/seed)
  - Tap notif → buka Detail Laporan
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171

### Milestone M6 — Kualitas & Deliverable UTS (Hari 13–14)

**Issue #14 — Seed data 10 barang & 10 lokasi Bandung + 3 notifikasi**

- Assignee: Alpin
- Label: `data`, `content`
- Acceptance Criteria:
  - 10 item (campuran lost/found) dengan foto & koordinat Bandung
  - 3 notifikasi contoh tampil
  - Refensi Design UI Aplikasi: https://www.figma.com/design/tHD2LbDX8IWtB3PekdnC5a/Project-UI-UX-Design-Aplikasi?node-id=123-171

**Issue #15 — Blackbox Testing (tabel + screenshot)**

- Assignee: Alpin (bantu Anda)
- Label: `testing`, `docs`
- Acceptance Criteria:
  - Tabel pengujian per fitur (skenario, expected, status Pass/Fail)
  - Screenshot bukti
  - Semua fitur MVP diuji (minimal 4 fitur)

**Issue #16 — Laporan UTS PDF (Bab I–IV) + Lampiran**

- Assignee: Anda (lead penulisan), Alpin (screenshot/diagram)
- Label: `docs`, `report`
- Acceptance Criteria:
  - PDF A4, margin 2.5cm, font Calibri/TNR 11–12pt, spasi 1.15
  - Cover, Bab I (analisis kebutuhan), Bab II (Dart/OOP/model), Bab III (Flutter/state/navigasi/screenshot), Bab IV (blackbox)
  - Lampiran: link GitHub, ZIP, video demo 3–5 menit

**Issue #17 — Video demonstrasi 3–5 menit**

- Assignee: Alpin (record), Anda (narasi)
- Label: `docs`, `demo`
- Acceptance Criteria:
  - Durasi 3–5 menit, narasi suara
  - Menunjukkan semua fitur MVP berjalan

## Definition of Done (per issue)

- Code berjalan di Chrome/Android, `flutter analyze` tanpa error, `flutter test` pass
- PR/commit dengan pesan konvensional, direview oleh anggota lain
- Screenshot/GIF untuk perubahan UI

## Catatan Risiko

- Batasan awal "no new deps" bertentangan dengan MVP (butuh Firebase/map/notif). Keputusan: tambah deps free-tier (Issue #2) dan dokumentasikan di laporan.
- Apple Sign-In butuh akun developer berbayar → jadikan placeholder atau gunakan Google only untuk UTS.
- Quota Firestore Spark (50k read/hari) cukup untuk demo; hindari query berat.

## Label & Milestone Saran (GitHub)

- Labels: `setup`, `feature`, `backend`, `ui`, `map`, `auth`, `chat`, `notifications`, `testing`, `docs`, `bug`, `priority:high`
- Milestones: `M0 Setup`, `M1 Auth`, `M2 Data & Laporan`, `M3 Peta`, `M4 Klaim & Chat`, `M5 Notifikasi`, `M6 Deliverable UTS`


---
**Status:** Issues #1-#17 sudah dibuat di GitHub (Adityabeckham/FoundItApps) dengan assignee & milestone sesuai dokumen ini.



## Tambahan (issue #18-#20)
- #18 Setup state management (Provider) & routing terpusat — Anda — M0
- #19 Empty states & error handling global — Alpin — M2
- #20 Halaman Detail Laporan (terpisah) — Alpin — M2



## Catatan pembaruan
- Task yang butuh Firebase (issue #1,#2,#3,#4,#5,#6,#7,#11,#12,#14) dipindahkan ke Anda (Adityabeckham) karena memakai akun Firebase Anda.
- Task UI (#4,#5,#6,#7,#8,#9,#10,#11,#12,#13,#19,#20) dilengkapi deskripsi link Figma + referensi struktur code di SlicingUi.md.

