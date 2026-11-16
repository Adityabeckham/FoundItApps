

Nama Matakuliah/SKS : Pemrograman Mobile II / 3 SKS  

Dosen : Dedi Rosadi, S.Kom. 

Waktu/Sifat Ujian : 120 Menit/ Take Home 

Kelas : TIF RP 24B CID  

Ujian Tengah Semester (UTS) mata kuliah Pemrograman Mobile II dilaksanakan dalam bentuk pelaporan  

progres (*milestone report*) dan demonstrasi proyek aplikasi mobile berbasis Flutter & Dart yang telah  dikembangkan oleh masing-masing mahasiswa/kelompok selama proses perkuliahan. Mahasiswa diwajibkan membangun dan mengembangkan sebuah proyek aplikasi mobile berbasis Flutter  & Dart sesuai dengan ide, kebutuhan, dan permasalahan yang telah ditentukan. Proyek tersebut harus  diimplementasikan secara fungsional dengan menerapkan konsep pemrograman Dart, pengembangan  antarmuka Flutter, navigasi antar halaman, pengelolaan state, serta pengujian fungsional aplikasi. Melalui ujian ini, mahasiswa diharapkan mampu menunjukkan proses pengembangan aplikasi secara  menyeluruh, mulai dari analisis kebutuhan, perancangan sistem, implementasi kode program, hingga  pengujian dan demonstrasi hasil aplikasi. 

Penilaian UTS didasarkan pada empat komponen capaian pembelajaran mata kuliah (CPMK), yaitu: 1\. Analisis Kebutuhan Sistem. 

2\. Teori dan Praktik Pemrograman Dart. 

3\. Implementasi Flutter dan State Management. 

4\. Praktik Pengujian Sistem. 


SISTEMATIKA LAPORAN UJIAN  

Laporan UTS disusun dalam format PDF dengan ketentuan: 

• Ukuran kertas A4. 

• Margin 2,5 cm pada seluruh sisi. 

• Font Calibri atau Times New Roman. 

• Ukuran font 11 atau 12 pt. 

• Spasi 1,15. 

• Bahasa Indonesia yang baku dan sistematis. 

HALAMAN COVER  

Memuat: 

1\. Judul proyek aplikasi. 

2\. Logo perguruan tinggi. 

3\. Nama mahasiswa/anggota kelompok. 

4\. NIM masing-masing mahasiswa. 

5\. Kelas. 

6\. Nama dosen pengampu. 

7\. Program studi dan tahun akademik. 

BAB I. ANALISIS KEBUTUHAN SISTEM  

Analisis Kebutuhan Sistem  

1.1. Latar Belakang dan Identifikasi Masalah 

Menjelaskan permasalahan nyata yang menjadi dasar pengembangan aplikasi. 

1.2. Tujuan Pengembangan Aplikasi 

Menjelaskan tujuan dan manfaat aplikasi dalam menyelesaikan permasalahan pengguna. 1.3. Target Pengguna 

Mengidentifikasi calon pengguna dan karakteristik pengguna aplikasi. 

1.4. Kebutuhan Fungsional 

Menjelaskan minimal 4 fitur utama yang telah diimplementasikan sampai dengan progres UTS. 1.5. Perancangan Alur Aplikasi 

Menyertakan flowchart, use case sederhana, atau diagram alur navigasi pengguna. 1.6. Perancangan Antarmuka 

Menyertakan mockup atau rancangan tampilan aplikasi. 

BAB II. LOGIKA DAN PENERAPAN BAHASA DART  

Teori dan Praktik Dart 

2.1. Struktur Program Dart 

Menjelaskan struktur kode dan pembagian file program. 

2.2. Penerapan Object-Oriented Programming (OOP) 

Menjelaskan class, object, constructor, atribut, method, dan konsep OOP yang digunakan.

2.3. Perancangan Model Data 

Menjelaskan struktur class model, tipe data, serta hubungan antarobjek jika ada. 

2.4. Implementasi Struktur Data 

Menjelaskan penggunaan List, Map, atau Set dalam pengelolaan data aplikasi. 

2.5. Penerapan Null-Safety 

Menjelaskan penggunaan nullable dan non-nullable variables serta penanganan nilai null. 2.6. Implementasi Logika Bisnis 

Menjelaskan fungsi dan proses komputasi yang digunakan, seperti kalkulasi, validasi, filter, pencarian,  atau pengolahan data. 

Ketentuan: Setiap pembahasan implementasi wajib menyertakan cuplikan kode program dan penjelasan  fungsi kode tersebut. 

BAB III. IMPLEMENTASI FLUTTER DAN STATE MANAGEMENT  

Implementasi Flutter 

3.1. Struktur Proyek Flutter 

Menjelaskan struktur direktori dan pembagian file aplikasi. 

3.2. Implementasi Widget Flutter 

Menjelaskan penggunaan widget utama seperti Scaffold, AppBar, Container, Column, Row, ListView, Card,  Form, dan widget lainnya. 

3.3. Implementasi Navigasi 

Menjelaskan mekanisme perpindahan halaman, routing, Navigator.push, Navigator.pop, serta pengiriman  data antarhalaman. 

3.4. Implementasi State Management 

Menjelaskan mekanisme pengelolaan state menggunakan StatefulWidget, Provider, atau metode lainnya. 3.5. Dokumentasi Tampilan Aplikasi 

Menyertakan screenshot seluruh halaman aplikasi yang telah berhasil diimplementasikan. 3.6. Demonstrasi Fitur Aplikasi 

Menjelaskan cara kerja fitur utama beserta hasil implementasinya.

BAB IV. PRAKTIK PENGUJIAN SISTEM  

Praktik Pengujian 

4.1. Metode Pengujian 

Menjelaskan metode Blackbox Testing yang digunakan untuk menguji fungsionalitas aplikasi. 4.2. Skenario Pengujian 

Menyusun tabel pengujian berdasarkan fitur dan kemungkinan kondisi input. 

4.3. Hasil Pengujian 

Menyajikan hasil pengujian berdasarkan status berhasil (Pass) atau gagal (Fail). 

4.4. Dokumentasi Pengujian 

Menyertakan screenshot hasil pengujian sebagai bukti bahwa fungsi aplikasi berjalan sesuai harapan. LAMPIRAN  

1\. Tautan repository GitHub/GitLab yang berisi source code aplikasi. 

2\. Tautan Google Drive yang berisi arsip proyek Flutter dalam format ZIP. 

3\. Video demonstrasi aplikasi berdurasi 3–5 menit dengan narasi suara. 

4\. Dokumentasi tambahan apabila diperlukan. 

FORMAT TABEL PENGUJIAN BLACKBOX TESTING  

Mahasiswa wajib menyusun tabel pengujian dengan format berikut: 

| No.  | Fitur yang   Diuji | Skenario / Aksi Masukan  | Hasil yang Diharapkan  | Status |
| ----- | ----- | :---- | ----- | ----- |
| 1  | Validasi Form  | Menekan tombol simpan ketika  field wajib kosong | Muncul pesan validasi dan data  tidak disimpan | Pass/Fail |
| 2  | Logika Bisnis  | Memasukkan nilai kuantitas  dan harga | Total perhitungan sesuai rumus  | Pass/Fail |
| 3  | Navigasi  | Mengetuk salah satu item pada  daftar | Berpindah ke halaman detail  dengan data yang benar | Pass/Fail |
| 4  | Input Data  | Memasukkan data dengan  format tidak valid | Sistem menolak input dan   memberikan pesan kesalahan | Pass/Fail |
| 5  | Pengelolaan   Data | Menambahkan, mengubah,  atau menghapus data | Data berubah sesuai tindakan  pengguna | Pass/Fail |

Catatan: Skenario pengujian harus disesuaikan dengan fitur yang benar-benar tersedia pada masing-

masing aplikasi. Mahasiswa tidak diperkenankan mengisi status Pass apabila pengujian belum dilakukan. 

KETENTUAN PELAKSANAAN UJIAN  

1\. Pengumpulan Laporan 

• Laporan UTS dikumpulkan dalam format PDF melalui LMS/e-learning. 

• Laporan wajib diunggah sebelum sesi presentasi dimulai. 

• Mahasiswa wajib memastikan file dapat dibuka dan seluruh bagian laporan telah lengkap. 2\. Pelaksanaan Presentasi dan Demonstrasi 

• Setiap mahasiswa/kelompok memperoleh waktu presentasi sekitar 7–10 menit. • Presentasi mencakup penjelasan proyek, implementasi teknis, dan demonstrasi aplikasi. • Dosen dapat memberikan pertanyaan terkait konsep Dart, Flutter, struktur kode, dan logika program. • Mahasiswa wajib mampu menjelaskan bagian kode yang telah diimplementasikan. 3\. Kesiapan Perangkat 

• Mahasiswa wajib mempersiapkan laptop/PC dan emulator Android atau smartphone. • Aplikasi harus sudah dapat dijalankan sebelum sesi ujian dimulai. 

• Pastikan koneksi perangkat, Android Debug Bridge (ADB), dan screen mirroring telah dipersiapkan  apabila diperlukan. 

4\. Originalitas dan Penguasaan Kode 

• Setiap mahasiswa bertanggung jawab atas kode program yang dikumpulkan. 

• Mahasiswa wajib memahami implementasi kode yang digunakan. 

• Ketidakmampuan menjelaskan kode atau indikasi plagiarisme dapat memengaruhi penilaian terkait. • Penggunaan referensi, library, maupun bantuan AI diperbolehkan sepanjang penggunaannya dapat  dipertanggungjawabkan dan mahasiswa memahami implementasinya. 

INSTRUKSI AKHIR UJIAN  

Sebelum mengikuti ujian, pastikan seluruh komponen berikut telah dipersiapkan: 

1\. Laporan UTS dalam format PDF bersisi LINK G-DRIVE (Wajib akses dibuka) semua file dimasukan  kedalam G-Drive. 

2\. Source code proyek Flutter yang dapat dijalankan. 

3\. Minimal 4 fitur utama yang telah diimplementasikan. 

4\. Dokumentasi screenshot seluruh halaman aplikasi.

5\. Tabel pengujian Blackbox Testing. 

6\. Video demonstrasi aplikasi berdurasi 3–5 menit. 

SELAMAT MENGERJAKAN UJIAN TENGAH SEMESTER (UTS) 

*Demonstrasikan hasil karya terbaik, pahami setiap implementasi kode, dan tunjukkan bahwa aplikasi yang  dikembangkan benar-benar berfungsi sesuai kebutuhan.*