# Bukti Screenshot Pengujian (Blackbox)

Simpan screenshot hasil pengujian di folder ini dengan nama file berikut.
Ambil screenshot dari perangkat Android (disarankan) atau `flutter run -d chrome`.

| Nama File | Skenario yang Ditampilkan |
| ----- | ----- |
| `01-login-google.png` | Halaman login dan/atau hasil login Google berhasil. |
| `03-dashboard.png` | Dashboard katalog dengan daftar laporan. |
| `04-search-filter.png` | Hasil pencarian kata kunci + filter kategori/status aktif. |
| `06-report-form.png` | Form laporan terisi (Hilang/Ditemukan) + pesan validasi. |
| `10-location-picker.png` | Peta pemilihan lokasi + preview peta pada form. |
| `12-map-radius.png` | Peta dengan radius 1/3/5 km + Bottom Sheet pin. |
| `15-claim.png` | Halaman klaim: status Approved (dan/atau Rejected Limit Exceeded). |
| `18-chat.png` | Ruang chat dengan bubble kanan/kiri dan timestamp. |
| `20-notification.png` | Notifikasi lokal tampil (tray Android) + layar notifikasi. |
| `21-empty-error.png` | Empty state (pencarian kosong) dan error state + "Coba Lagi". |

## Cara Mengambil Screenshot

1. Jalankan aplikasi: `flutter run -d chrome` (cepat) atau pada perangkat Android.
2. Lakukan skenario sesuai tabel di `docs/BLACKBOX_TESTING.md`.
3. Simpan screenshot dengan nama file di atas (format PNG).
4. Verifikasi status Pass/Fail pada tabel setelah screenshot diambil.

> Screenshot tidak dibuat otomatis oleh tooling; wajib diambil manual saat
> pengujian agar sesuai ketentuan "tidak mengisi Pass bila belum diuji".
