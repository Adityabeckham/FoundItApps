import 'package:flutter/material.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/theme/app_spacing.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: AppSpacing.s24),
                    _buildTextContent(),
                  ],
                ),
              ),
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 280,
      width: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -16,
            top: -16,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                color: const Color(0xFFDBE1FF).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Positioned(
            left: 120,
            top: 128,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E4FE).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 176,
              height: 176,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x14000000),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/images/icon-apps.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      children: [
        Text(
          'FoundIt',
          textAlign: TextAlign.center,
          style: AppTextStyles.display32.copyWith(
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          "Lost it? Let's Find It Together.",
          textAlign: TextAlign.center,
          style: AppTextStyles.headingM20.copyWith(
            fontSize: 18,
            color: AppColors.primaryPressed,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            'Platform penemuan barang hilang terhubung\ndengan ribuan orang baik di sekitarmu secara\ninstan dan aman.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyL14.copyWith(
              color: AppColors.textSecondary,
              height: 1.63,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0C000000),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E4FE),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E4FE),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/onboarding2');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bgInverse,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'LANJUT',
              style: AppTextStyles.labelXl15.copyWith(
                color: Colors.white,
                letterSpacing: 0.38,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

