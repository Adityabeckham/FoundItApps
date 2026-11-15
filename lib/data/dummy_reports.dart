import '../models/item_report.dart';
import '../theme/app_colors.dart';

/// Data contoh laporan untuk dashboard (MVP UTS).
const List<ItemReport> dummyReports = [
  ItemReport(
    title: 'Dompet Kulit Cokelat',
    location: 'Stasiun Bandung',
    timeAgo: '2 jam lalu',
    imageAsset: 'assets/images/dompet-kulit-cokelat.png',
    isLost: true,
    thumbBackground: AppColors.categoryOrangeBg,
    category: 'Dompet',
  ),
  ItemReport(
    title: 'Kunci Motor Honda',
    location: 'Gedung Sate',
    timeAgo: '3 jam lalu',
    imageAsset: 'assets/images/kunci-motor-honda.png',
    isLost: false,
    thumbBackground: AppColors.categoryBlueBg,
    category: 'Kunci',
  ),
  ItemReport(
    title: 'Laptop ASUS Vivobook',
    location: 'Kampus ITB',
    timeAgo: '5 jam lalu',
    imageAsset: 'assets/images/asus-vivobook.png',
    isLost: true,
    thumbBackground: AppColors.categoryGreenBg,
    category: 'Elektronik',
  ),
  ItemReport(
    title: 'Tas Ransel Hitam',
    location: 'Paris Van Java',
    timeAgo: 'Kemarin',
    imageAsset: 'assets/images/tas-ransel-hitam.png',
    isLost: false,
    thumbBackground: AppColors.categoryPurpleBg,
    category: 'Tas',
  ),
];


