# Tema FoundIt (dari Figma Design System)

Token di sini sama persis dengan Figma: halaman Page 1, frame
"Design System - Foundations" dan "Design System - Components".

## 1. Salin file

Salin folder `lib/theme/` ke project Flutter (`lib/theme/`):

- `app_colors.dart`       warna (koleksi Color di Figma)
- `app_spacing.dart`      spacing dan radius
- `app_shadows.dart`      bayangan
- `app_text_styles.dart`  text style (Plus Jakarta Sans)
- `app_theme.dart`        ThemeData: tombol, input, chip, kartu, app bar, bottom nav

## 2. Daftarkan font Plus Jakarta Sans

Unduh dari Google Fonts (Plus Jakarta Sans), taruh di `assets/fonts/`:
`PlusJakartaSans-Regular.ttf`, `-SemiBold.ttf`, `-Bold.ttf`, `-ExtraBold.ttf`.

Tambahkan ke `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  fonts:
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Regular.ttf
        - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700
        - asset: assets/fonts/PlusJakartaSans-ExtraBold.ttf
          weight: 800
```

Tanpa file font, aplikasi tetap jalan memakai font bawaan (tampilan sedikit beda).
Dengan font di assets, tidak perlu internet saat demo di HP.

## 3. Pasang di main.dart

```dart
import 'theme/app_theme.dart';

MaterialApp(
  title: 'FoundIt',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  home: const ...,
);
```

## 4. Aturan pakai (supaya UI konsisten)

- Warna hanya dari `AppColors`, jangan tulis `Color(0xFF...)` di widget.
- Teks hanya dari `AppTextStyles` atau `Theme.of(context).textTheme`.
- Jarak dari `AppSpacing`, sudut dari `AppRadius`.
- Tombol: `ElevatedButton` (Primary), `OutlinedButton` (Secondary). Danger dan
badge dibuat sebagai widget kecil sendiri memakai `errorBg` dan `error`.
- Ikon di Figma memakai Lucide (stroke 2). Di Flutter pakai ikon Material yang
paling mirip, atau tambahkan paket `lucide_icons_flutter` kalau mau persis sama.

## 5. Pemetaan komponen Figma ke Flutter

| Komponen Figma | Widget Flutter |
|---|---|
| Button (Primary/Secondary/Disabled) | ElevatedButton / OutlinedButton (sudah di tema) |
| Input Field (Default/Focus/Error) | TextFormField (sudah di tema, `errorText` untuk Error) |
| Chip (Selected) | ChoiceChip / FilterChip (warna teks terpilih diatur di widget) |
| Badge (Hilang/Ditemukan/...) | widget `StatusBadge` buatan sendiri |
| Item Card | widget `ItemCard` buatan sendiri di atas `Card` |
| Nav Item / Bottom Nav | BottomNavigationBar (sudah di tema) + `AppShadows.barUp` |
