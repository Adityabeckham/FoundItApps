# Pengujian Blackbox Testing — FoundIt

Dokumen ini memenuhi **BAB IV. Praktik Pengujian Sistem** pada UTS.

## 4.1 Metode Pengujian

Pengujian menggunakan metode **Blackbox Testing**, yaitu pengujian fungsionalitas
aplikasi dari sudut pandang pengguna tanpa memperhatikan struktur kode internal.
Setiap fitur diuji dengan memberikan aksi masukan (input) tertentu lalu
membandingkan hasil aktual dengan hasil yang diharapkan (*expected*).

Aspek yang diuji:

- **Validasi input** — form laporan, pertanyaan/jawaban rahasia, jawaban klaim.
- **Logika bisnis** — verifikasi jawaban klaim dan batas 3 percobaan.
- **Navigasi** — perpindahan antar halaman dan pengiriman data via route arguments.
- **Pengelolaan data** — simpan laporan/klaim/chat ke Cloud Firestore.
- **Keamanan akses** — tombol klaim hanya untuk pengguna yang berhak.

Sebagian skenario juga diverifikasi otomatis melalui `flutter test`
(`test/claim_service_test.dart`, `test/detail_report_screen_test.dart`,
`test/state_views_test.dart`, `test/notification_service_test.dart`,
`test/widget_test.dart`).

## 4.2 Skenario & 4.3 Hasil Pengujian

| No. | Fitur yang Diuji | Skenario / Aksi Masukan | Hasil yang Diharapkan | Status |
| ----- | ----- | :---- | ----- | ----- |
| 1 | Autentikasi (Google Sign-In) | Menekan tombol "Masuk dengan Google" dan memilih akun | Pengguna berhasil masuk dan diarahkan ke Dashboard | Pass |
| 2 | Autentikasi (Logout) | Menekan tombol logout pada halaman Profil | Sesi berakhir dan pengguna kembali ke halaman login/onboarding | Pass |
| 3 | Dashboard Katalog | Membuka aplikasi setelah login | Daftar laporan barang tampil (dari Firestore/seed) | Pass |
| 4 | Pencarian | Mengetik kata kunci (mis. "tas") pada kolom cari | Daftar terfilter menampilkan laporan yang cocok (judul/lokasi/deskripsi) | Pass |
| 5 | Filter Kategori/Status | Memilih chip "Hilang"/"Ditemukan"/kategori | Daftar hanya menampilkan laporan sesuai filter | Pass |
| 6 | Validasi Form Laporan | Menekan "Kirim Laporan" saat field wajib kosong | Muncul pesan validasi dan data tidak disimpan | Pass |
| 7 | Validasi Form Laporan | Mengirim laporan tanpa foto | Muncul pesan "Unggah minimal 1 foto barang" dan data tidak disimpan | Pass |
| 8 | Validasi Form Laporan | Laporan "Ditemukan" tanpa pertanyaan/jawaban rahasia | Muncul pesan validasi pertanyaan rahasia wajib diisi | Pass |
| 9 | Input Data Laporan | Mengisi form valid lalu menekan "Kirim Laporan" | Laporan tersimpan ke Firestore `items` dan muncul di Dashboard | Pass |
| 10 | Location Picker (Peta) | Menekan "Pilih Lokasi di Peta" lalu mengetuk titik pada peta | Koordinat lat/lng diperoleh, nama tempat terisi, dan preview peta tampil | Pass |
| 11 | Location Picker (Lokasi Saya) | Menekan ikon "Lokasi Saya" lalu menyetujui izin lokasi | Koordinat perangkat diperoleh dan preview peta menampilkan lokasi | Pass |
| 12 | Peta Radius (Lost Around Me) | Memilih radius 1 km / 3 km / 5 km | Daftar "Laporan Terdekat" diperbarui sesuai radius dari posisi pengguna | Pass |
| 13 | Navigasi Pin Peta | Mengetuk pin laporan pada peta | Muncul Bottom Sheet ringkasan; tombol membuka Detail Laporan yang benar | Pass |
| 14 | Klaim — Akses Tombol | Membuka detail laporan Hilang atau laporan milik sendiri | Tombol "Klaim" tidak ditampilkan | Pass |
| 15 | Klaim — Jawaban Benar | Menjawab seluruh pertanyaan rahasia dengan benar | Status klaim menjadi `Approved`, chat otomatis terbuka | Pass |
| 16 | Klaim — Batas Percobaan | Menjawab salah sebanyak 3 kali | Status `Rejected` dengan alasan `Limit Exceeded`, tombol klaim terkunci | Pass |
| 17 | Klaim — Bukti & Resolusi | Mengunggah bukti serah terima lalu "Konfirmasi Penyelesaian" | Status laporan berubah menjadi `Resolved` | Pass |
| 18 | Chat Real-time | Mengirim pesan pada ruang chat | Pesan tersimpan dan tampil real-time untuk kedua pengguna | Pass |
| 19 | Chat — Tampilan | Mengirim/menerima pesan | Bubble kanan untuk pesan sendiri, kiri untuk lawan bicara, dengan timestamp | Pass |
| 20 | Notifikasi Lokal | Memicu notifikasi barang temuan cocok / klaim baru | Notifikasi tampil; menekan notifikasi membuka Detail Laporan terkait | Pass |
| 21 | Empty & Error State | Mencari kata kunci yang tidak ada / mematikan koneksi | Tampil empty state atau pesan error + tombol "Coba Lagi" | Pass |

> Catatan: status `Pass` diisi berdasarkan pengujian lokal (manual + otomatis)
> yang telah dilakukan. Lampirkan screenshot bukti untuk setiap fitur sesuai
> daftar pada `docs/screenshots/README.md`.

## 4.4 Dokumentasi Pengujian (Screenshot)

Screenshot bukti pengujian disimpan pada folder `docs/screenshots/`.
Daftar nama file dan skenario yang harus diambil tersedia di
[`docs/screenshots/README.md`](screenshots/README.md).

| No. | Fitur | Nama File Bukti |
| ----- | ----- | ----- |
| 1 | Login Google | `01-login-google.png` |
| 3 | Dashboard Katalog | `03-dashboard.png` |
| 4–5 | Pencarian & Filter | `04-search-filter.png` |
| 6–9 | Form Laporan + Validasi | `06-report-form.png` |
| 10–11 | Location Picker | `10-location-picker.png` |
| 12–13 | Peta Radius + Bottom Sheet | `12-map-radius.png` |
| 15–16 | Klaim (Approved / Rejected) | `15-claim.png` |
| 18–19 | Chat Real-time | `18-chat.png` |
| 20 | Notifikasi Lokal | `20-notification.png` |
| 21 | Empty / Error State | `21-empty-error.png` |
