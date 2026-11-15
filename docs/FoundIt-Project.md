PROYEK: FOUNDIT

*Lost it? Let's Find It Together.*

**Platform Pencarian dan Pengelolaan Barang Hilang**

*Cakupan: UTS Pemrograman Mobile (dikerjakan berkelompok) dan Desain UI/UX*

# **1\. Ringkasan Eksekutif**

FoundIt adalah aplikasi mobile yang dirancang untuk membantu masyarakat menemukan kembali barang yang hilang secara aman, cepat, dan terorganisasi. Berbeda dari media sosial konvensional, FoundIt tidak hanya berfungsi sebagai papan pengumuman pasif, melainkan membangun ekosistem kolaboratif melalui pencarian terstruktur, pencocokan cerdas (Smart Match), serta sistem verifikasi kepemilikan yang menjamin privasi dan keamanan setiap pihak.

| Parameter | Keterangan |
| :---- | :---- |
| **Nama Aplikasi** | FoundIt |
| **Jenis / Kategori** | Mobile Application / Lifestyle & Community |
| **Platform Target** | Android (dibangun dengan Flutter) |
| **Gaya Desain** | Modern, Clean, Minimalis |
| **Model Layanan** | Community-based Platform |
| **Tingkat Kompleksitas** | Menengah (cakupan dipangkas untuk UTS Pemrograman Mobile, tenggat 2 minggu, dikerjakan berkelompok) |

# **2\. Identifikasi Masalah & Problem Statement**

## **2.1. Latar Belakang & Permasalahan**

Kehilangan barang pribadi merupakan insiden umum di ruang publik seperti kampus, transportasi umum, kafe, dan pusat perbelanjaan. Saat ini, proses pencarian menghadapi beberapa kendala nyata:

1\.     Informasi laporan kehilangan dan penemuan tersebar tanpa pola di berbagai grup chat (WhatsApp, Telegram) serta media sosial.

2\.     Ketiadaan sistem pencarian terpusat berbasis kategori, waktu, dan radius lokasi.

3\.     Penemu barang kerap bingung mencari saluran yang tepat untuk mengontak pemilik sah.

4\.     Rentan penyalahgunaan klaim palsu akibat tidak adanya mekanisme verifikasi kepemilikan yang terlindungi.

## **2.2. Problem Statement**

***"Bagaimana merancang aplikasi mobile yang dapat membantu masyarakat melaporkan, mencari, dan menemukan kembali barang yang hilang secara lebih mudah, terorganisasi, dan aman melalui kolaborasi aktif antar pengguna?"***

# **3\. Tujuan Proyek & Target Pengguna**

## **3.1. Tujuan Proyek**

•       Memfasilitasi pelaporan barang hilang dan ditemukan dalam satu wadah terpusat.

•       Mempercepat temu kembali barang dengan filter terstruktur dan peta lokasi.

•       Menyediakan proteksi privasi dan validasi kepemilikan sebelum serah terima.

•       Menumbuhkan budaya tolong-menolong dengan sistem penghargaan sosial dan gamifikasi (pengembangan lanjutan).

## **3.2. Target Pengguna & Peluang Pasar**

•       **Utama (Primary):** Masyarakat umum usia produktif (17–45+ tahun), mulai dari mahasiswa, komuter/pengguna transportasi umum, pekerja kantoran, hingga pengunjung fasilitas umum.

•       **Sekunder (Secondary):** Pengelola fasilitas publik (staf keamanan mall, pengelola stasiun, kafe, atau event organizer) yang sering menerima dan mengelola penyerahan barang hilang.

**Karakteristik Kunci:** Akrab dengan smartphone, mengutamakan kepraktisan, dan memiliki kesadaran sosial untuk membantu sesama.

# **4\. Nilai Keunggulan & Fitur Pembeda (Novelty)**

## **4.1. Unique Value Proposition (UVP)**

***"FoundIt makes lost and found easier through community-powered discovery, smart matching, and secure item recovery."***

Nilai utama berlandaskan 4 pilar: **Convenient** (satu aplikasi terpadu), **Connected** (menghubungkan penemu & pemilik), **Secure** (verifikasi kepemilikan privat), dan **Collaborative** (partisipasi komunitas).

## **4.2. Fitur Pembeda Utama**

•       **Lost Around Me (OpenStreetMap):** Penelusuran berbasis peta dan radius terdekat untuk memantau laporan kehilangan di sekitar pengguna (100% Free Tier). **\[Masuk UTS\]**

•       **Ownership Verification (Batas 3x Percobaan):** Pertanyaan rahasia (contoh: stiker laptop, nomor seri parsial) untuk mencegah klaim sembarangan. Percobaan dibatasi maksimal 3 kali per akun untuk mencegah tebakan asal/brute force. **\[Masuk UTS\]**

•       **In-App Chat Sederhana:** Obrolan real-time privat di dalam aplikasi (Firebase Cloud Firestore) yang menjaga privasi nomor telepon antar pengguna. **\[Masuk UTS\]**

•       **Smart Match:** Pencocokan otomatis berdasarkan kesamaan kategori, warna, deskripsi, dan radius lokasi. **\[Pengembangan lanjutan\]**

•       **Privasi Barang Sensitif:** Barang berdokumen (KTP, ATM, SIM) masuk kategori khusus dengan data sensitif disamarkan. **\[Pengembangan lanjutan\]**

•       **Good Samaritan Points & Leaderboard:** Poin reputasi bagi penemu yang berhasil mengembalikan barang, dengan Leaderboard Top 10 di dashboard. **\[Pengembangan lanjutan\]**

# **5\. Alur Pengguna (User Flow & Edge Cases)**

## **5.1. Alur Pemilik yang Kehilangan Barang (Lost Item Flow)**

1\.     Buka aplikasi FoundIt dan pilih menu "Lost Item".

2\.     Isi identitas barang: nama, kategori, ciri khusus, foto referensi, lokasi terakhir (via OpenStreetMap), dan opsi imbalan/reward.

3\.     **\[Happy Path\]** Sistem menampilkan daftar barang temuan yang cocok atau hasil filter pencarian. Pengguna memilih barang yang sesuai.

4\.     **\[Empty Path\]** Jika tidak ada barang temuan yang cocok: sistem menampilkan Empty State ("Belum ada barang temuan yang cocok di sekitar lokasi Anda"), laporan tersimpan dengan status Open, dan pengguna menerima notifikasi bila kelak ada barang temuan yang serupa.

5\.     Pengguna menekan "Klaim Barang" dan wajib menjawab pertanyaan rahasia yang dibuat penemu.

6\.     **\[Happy Path\]** Jawaban benar pada percobaan ke-1, 2, atau 3: status klaim menjadi Approved.

7\.     **\[Unhappy Path\]** Salah menjawab 3 kali berturut-turut: pengajuan klaim akun tersebut untuk barang itu diblokir, tombol klaim terkunci, dan status menjadi Rejected (Limit Exceeded).

8\.     Setelah klaim disetujui, In-App Chat privat otomatis terbuka antara pemilik dan penemu.

9\.     Pemilik dan penemu menyepakati waktu serta lokasi serah terima yang aman.

10\.  Setelah bertemu, pemilik mengonfirmasi penerimaan barang (unggah foto bukti terima bila perlu) dan status laporan berubah menjadi Resolved.

## **5.2. Alur Penemu Barang**

1\.     Pilih menu "Found Item": unggah foto barang, pilih kategori, isi lokasi penemuan, dan buat 1–3 Pertanyaan Rahasia untuk memvalidasi calon pemilik sah.

2\.     **\[Happy Path\]** Penemu menerima notifikasi klaim masuk beserta jawaban pertanyaan rahasianya.

3\.     **\[Empty Path\]** Jika belum ada yang mengklaim, laporan tampil di dashboard publik dengan status Waiting for Owner. Penemu dapat memperbarui deskripsi/lokasi bila barang dititipkan ke pihak ketiga (misal: pos satpam kampus atau kasir kafe).

4\.     **\[Happy Path\]** Jawaban cocok: penemu mengonfirmasi dan memulai obrolan via In-App Chat untuk menyepakati titik temu.

5\.     Penemu menyerahkan barang di lokasi fisik, lalu menekan "Tandai Selesai / Barang Diserahkan". Laporan ditutup (Resolved).

*Catatan: penyamaran data barang sensitif, fitur Report/Block User, dan pemberian Good Samaritan Points termasuk pengembangan lanjutan dan tidak diimplementasikan pada UTS.*

# **6\. Rencana Teknis & Implementasi UTS**

## **6.1. Cakupan Fitur: MVP UTS vs Pengembangan Lanjutan**

Agar proyek selesai dalam tenggat 2 minggu dengan anggaran 100% Free (\$0 Cost), fitur dibagi menjadi dua fase. Cakupan UTS ditetapkan sebanyak **9 fitur**.

**A. Fitur yang Dikerjakan pada UTS (MVP)**

| No | Fitur | Deskripsi Implementasi |
| :---- | :---- | :---- |
| 1 | Login Google | Autentikasi melalui Firebase Authentication (Free Tier). |
| 2 | Dashboard Katalog | Katalog visual laporan barang hilang dan ditemukan terkini, dengan halaman detail laporan. |
| 3 | Form Laporan | Formulir laporan barang hilang/ditemukan: nama, kategori, ciri khusus, foto, lokasi, dan imbalan (reward). |
| 4 | Pencarian & Filter | Pencarian kata kunci dan filter kategori. |
| 5 | Peta Radius OpenStreetMap | Peta interaktif (flutter\_map dan geolocator) dengan pin laporan dan penelusuran radius terdekat ("Lost Around Me"). |
| 6 | Klaim & Status Laporan | Klaim dengan pertanyaan rahasia (maks. 3 percobaan), status Open/Resolved, dan unggah bukti serah terima. |
| 7 | In-App Chat Privat Sederhana | Obrolan real-time privat antar pengguna setelah klaim disetujui (Cloud Firestore, Spark Plan \$0). |
| 8 | Notifikasi | Notifikasi lokal ketika ada barang temuan yang cocok atau klaim masuk (flutter\_local\_notifications, tanpa FCM). |
| 9 | Profil Dasar | Edit nama/foto profil dan logout. |

 

**B. Fitur yang Ditunda (Pengembangan Lanjutan)**

| Fitur | Deskripsi |
| :---- | :---- |
| Smart Match Otomatis | Pencocokan berdasarkan kesamaan kategori, warna, deskripsi, dan jarak. |
| Advanced Push Notification | Notifikasi push real-time (FCM) dan alert pencocokan otomatis. |
| Good Samaritan Points & Leaderboard | Poin reputasi, badge, dan Leaderboard Top 10 di dashboard. |
| Keamanan Lanjutan & Report User | Verifikasi identitas tambahan (KTM/KTP) serta blokir/laporkan pengguna. |
| Kategori Barang Sensitif | Penyamaran data sensitif pada barang berdokumen (KTP, ATM, SIM) hingga verifikasi lolos. |

 

## **6.2. Cakupan Data Selaras dengan Mata Kuliah Desain UI/UX**

Proyek ini digunakan bersama pada mata kuliah Desain UI/UX. Data dan layar yang sama dipakai sebagai seed data aplikasi:

•       **10 barang** hilang/ditemukan (data contoh).

•       **10 lokasi** di wilayah Kota Bandung. Pada desain Figma ditampilkan dengan screenshot Google Maps; pada aplikasi ditampilkan sebagai pin OpenStreetMap.

•       **Notifikasi** ketika ada barang yang ditemukan (contoh pada desain: 3 notifikasi barang ditemukan).

## **6.3. Arsitektur Teknologi (100% Free Tier Stack)**

| Komponen / Layer | Teknologi & Fungsi | Status Biaya |
| :---- | :---- | :---- |
| **Frontend Mobile UI** | Flutter (UI responsif dan modern) | 100% Open Source / Free |
| **Autentikasi** | Firebase Authentication (Google Auth) | 100% Free (Spark Plan) |
| **Database & Chat** | Cloud Firestore (data dan chat real-time) | 100% Free (Spark: 50k read/hari) |
| **Media Storage** | Firebase Storage (foto barang) | 100% Free (Spark: 5GB) |
| **Peta & Geolocation** | OpenStreetMap (flutter\_map, geolocator) | 100% Free (tanpa API Key/kartu kredit) |
| **Notifikasi** | flutter\_local\_notifications (notifikasi lokal) | 100% Free |

 

## **6.4. Pemetaan Layanan Firebase untuk FoundIt**

| Layanan | Peran dalam Aplikasi | Kuota Spark Plan |
| :---- | :---- | :---- |
| **Firebase Authentication** | Login pengguna (Google Sign-In). | Gratis tanpa batas |
| **Cloud Firestore** | Database laporan barang dan engine In-App Chat real-time (snapshots()). | 50.000 reads dan 20.000 writes / hari |
| **Firebase Storage** | Penyimpanan foto barang dan bukti serah terima. | Kapasitas 5 GB |
| **OpenStreetMap (flutter\_map)** | Visualisasi lokasi dan peta interaktif. | Gratis, tanpa API Key |

 

## **6.5. Skema Biaya Cloud Firestore**

| Komponen | Spark Plan (Gratis) | Blaze Plan (Pay-As-You-Go) |
| :---- | :---- | :---- |
| **Document Reads** | 50.000 dokumen / hari | \~\$0.06 per 100.000 dokumen |
| **Document Writes** | 20.000 dokumen / hari | \~\$0.18 per 100.000 dokumen |
| **Document Deletes** | 20.000 dokumen / hari | \~\$0.02 per 100.000 dokumen |
| **Data Storage** | 1 GiB total | \~\$0.18 per GiB / bulan |
| **Network Egress** | 10 GiB / bulan | \~\$0.12 per GiB (tergantung region) |
| **Kartu Kredit** | Tidak perlu | Perlu verifikasi kartu kredit/debit |
| **Kebutuhan Aplikasi** | Ideal untuk UTS, UAS, prototype, dan demo | Untuk aplikasi publik skala produksi besar |

 

# **7\. Ringkasan Ekstraksi Proyek**

•       **Ide Proyek:** FoundIt adalah platform mobile berbasis komunitas untuk membantu masyarakat melaporkan, mencari, dan menemukan kembali barang hilang secara terstruktur, cepat, dan aman.

•       **Target Pengguna:** Utama: masyarakat umum produktif (17–45+ tahun) seperti mahasiswa, komuter, pekerja kantoran, dan pengunjung fasilitas umum. Sekunder: pengelola fasilitas publik (staf keamanan mall/stasiun, kafe, event organizer).

•       **Problem Statement:** Informasi barang hilang tersebar di grup chat/sosmed, tidak ada pencarian terpusat berbasis lokasi/kategori, penemu bingung menghubungi pemilik sah, dan klaim palsu marak akibat ketiadaan verifikasi kepemilikan.

•       **Solusi & Kebaruan:** Platform terpadu dengan penelusuran sekitar lokasi berbasis OpenStreetMap, verifikasi kepemilikan privat (maks. 3 percobaan), dan In-App Chat privat berbasis Firebase. Smart Match, penanganan barang sensitif, dan gamifikasi poin menjadi pengembangan lanjutan.

•       **Fitur UTS (9 fitur):** Login Google, Dashboard katalog, Form laporan (+ foto, lokasi, imbalan), Pencarian dan filter kategori, Peta radius OpenStreetMap, Klaim (maks. 3x) dan status Open/Resolved dengan bukti serah terima, In-App Chat privat sederhana, Notifikasi, serta Profil dasar.

•       **Desain UI/UX:** Modern, clean, dan minimalis; dibangun dengan Flutter. Prototype tersedia di Figma.

•       **Alur Pengguna:** Pemilik melapor dan mengisi detail barang, sistem/filter mencocokkan, pemilik mengajukan klaim dan menjawab verifikasi rahasia (maks. 3x), koordinasi via In-App Chat, lalu penyerahan barang dan penutupan laporan.

•       **Kesimpulan:** FoundIt mengombinasikan teknologi dan kolaborasi komunitas untuk menciptakan ekosistem pengembalian barang hilang yang aman dan terorganisasi, serta dapat diimplementasikan 100% gratis (\$0 Cost) untuk MVP UTS hingga pengembangan lanjutan.

