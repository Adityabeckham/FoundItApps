# Firebase & Upload Setup Checklist - FoundIt

Panduan konfigurasi backend agar aplikasi berjalan end-to-end.

## Info project

| Item | Nilai |
| ----- | ----- |
| Firebase project | `foundit-apps` |
| Android package | `com.foundit.foundit` |
| Config files | `android/app/google-services.json`, `lib/firebase_options.dart` |
| Firestore rules | `firestore.rules` (+ `firebase.json`) |
| Upload gambar | **Cloudinary** (cloud `xauw8s47`, preset `laporan`, unsigned) |
| Login | Google Auth |

Catatan: **Firebase Storage tidak dipakai** (tidak perlu Blaze/kartu). Foto
diunggah ke Cloudinary, lalu URL-nya disimpan di Firestore.

## Status saat ini

- [x] SHA-1 sudah didaftarkan di Firebase (login Google).
- [x] Firestore Database sudah dibuat.
- [x] `firestore.rules` lolos kompilasi (dry-run).
- [x] Upload gambar via Cloudinary diimplementasikan
  ```
  (`lib/services/image_upload_service.dart`).
  ```
- [x] Rules Firestore belum di-deploy ke project.
- [x] Provider **Google** aktif (Email/Password tidak digunakan).

## 1. Authentication

- [x] **Authentication > Sign-in method > Google = Enabled**.
- [x] SHA-1 debug sudah ditambahkan (jika belum, lihat langkah di bawah).

Ambil SHA-1 (Windows):

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

## 2. Firestore

- [x] Database Firestore sudah dibuat (region mis. asia-southeast2 / Jakarta).
- [x] Deploy rules:

```powershell
firebase deploy --only firestore:rules --project foundit-apps
```

- [x] Koleksi dibuat otomatis saat app menulis: `items`, `claims`, `chats`,
  ```
  `chats/{chatId}/messages`. Tidak perlu membuat manual.
  ```
- [x] `users` hanya dibaca (untuk nama chat); jika kosong, nama tampil "Pengguna".

## 3. Upload gambar (Cloudinary)

- [x] Akun Cloudinary gratis (tanpa kartu).
- [x] Upload preset **unsigned**: nama `laporan`.
- [x] Cloud name `xauw8s47` dan preset sudah ada di
  ```
  `lib/services/image_upload_service.dart`.
  ```
- [x] Jangan pernah menaruh **API Secret** di aplikasi (unsigned upload tidak
  ```
  membutuhkannya).
  ```
- [x] Dipakai untuk: foto laporan, bukti serah terima klaim, foto profil.

## 4. Deploy

```powershell
npm install -g firebase-tools   # sekali saja
firebase login
firebase use foundit-apps
firebase deploy --only firestore:rules
```

Storage tidak perlu di-deploy karena tidak dipakai. File `storage.rules`
disimpan hanya jika nanti ingin pindah ke Firebase Storage.

## 5. Testing di MuMu Player

- [x] Login pakai **Google Sign-In**. Jika MuMu tidak punya Google Play Services,
  gunakan HP Android asli (teman) untuk pengujian autentikasi.
- [x] Aktifkan ADB di MuMu, lalu `adb connect 127.0.0.1:7555` (port bisa beda)
  ```
  dan `flutter devices`.
  ```
- [x] Jalankan `flutter run -d <device-id>`.
- [x] Set lokasi palsu di MuMu untuk uji peta/radius/"Lokasi Saya".
- [x] Notifikasi lokal hanya tampil di Android (tidak di web).

## 6. Smoke test

- [x] Login (Google) masuk ke Dashboard.
- [x] Dashboard menampilkan laporan (seed lokal / Firestore).
- [x] Buat laporan + upload foto -> tersimpan (`items`, URL Cloudinary).
- [x] Klaim dengan jawaban benar -> `Approved`, chat terbuka.
- [x] Kirim pesan chat -> tersimpan real-time.
- [x] Upload bukti klaim -> status laporan `Resolved`.
- [x] Notifikasi lokal muncul -> tap membuka Detail.

## 7. Hardening sebelum production

- [x] Verifikasi jawaban klaim di server (Cloud Function); saat ini dicek di
  ```
  client karena `secretAnswers` disimpan di dokumen `items`.
  ```
- [x] Firebase App Check (Play Integrity / reCAPTCHA).
- [x] Backup Firestore + budget alert Google Cloud.
- [x] Jika memakai Storage nanti: nonaktifkan akses publik & batasi CORS.
- [x] Uji rules dengan Rules Playground sebelum rilis.
