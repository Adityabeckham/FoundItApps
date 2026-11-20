# Dokumentasi FoundIt

Indeks dokumen proyek FoundIt.

| File | Keterangan |
| :---- | :---- |
| `FoundIt-Project.md` | Ringkasan proyek, masalah, fitur, arsitektur, biaya. |
| `FIRESTORE_SCHEMA.md` | Skema koleksi Firestore (users, items, claims, chats, messages). |
| `FIREBASE_SETUP.md` | Checklist setup Firebase & Cloudinary + rules production. |
| `BLACKBOX_TESTING.md` | Tabel pengujian Blackbox per fitur. |
| `SlicingUi.md` | Referensi slicing UI dari Figma (Profile, Pencarian & Filter, Peta). |
| `UTS TIF Ganjil 2026-2027 TIF RP 24B CID.md` | Ketentuan UTS (format laporan, blackbox, deliverable). |
| `TEMA-DESIGN.md` | Catatan tema & design system. |
| `screenshots/` | Bukti screenshot pengujian. |
| `firestore.rules` | Rules Firestore (production). |
| `storage.rules` | Rules Storage (opsional, tidak dipakai; upload via Cloudinary). |

## Struktur kode (ringkas)

```
lib/
  main.dart, firebase_options.dart
  core/            (theme, utils)   # saat ini: theme/, utils/
  data/            (dummy_reports, firestore_collections)
  models/          (item_report: ItemReport, AppUser, Claim, ChatMessage)
  providers/       (AuthProvider, ItemProvider)
  screens/
    auth/          (auth_gate, login, onboarding1/2)
    dashboard/     (dashboard)
    reports/       (report_form, detail_report, reports_list, filter_search, location_picker)
    map/           (map_screen)
    chat/          (chat_list, chat_room)
    claim/         (claim_screen)
    profile/       (profile_screen)
    notifications/ (notifications_screen)
  services/        (chat, claim, image_upload, reverse_geocoding, notifications/)
  widgets/         (app_bottom_nav, map_preview, report_card, state_views, status_badge, top_banner)
```
