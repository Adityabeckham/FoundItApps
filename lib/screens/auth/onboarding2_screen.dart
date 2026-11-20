import 'package:flutter/material.dart';
import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/theme/app_spacing.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

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
              _buildHeader(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIllustration(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/icon-apps.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'FoundIt',
            style: AppTextStyles.headingM20.copyWith(
              fontSize: 19,
              color: AppColors.bgInverse,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -30,
            top: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E4FE).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Positioned(
            right: -20,
            top: 0,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E7FF).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFDBE1FF).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 50,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E4FE).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/onboarding-2.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Column(
        children: [
          Text(
            'Satu Wadah Untuk\nSaling Menolong',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingL22.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.55,
              height: 1.38,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
            child: Text(
              'Temukan barangmu yang hilang atau bantu\nkembalikan barang orang lain dengan aman,\ntransparan, dan penuh rasa percaya.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyL14.copyWith(
                color: AppColors.textSecondary,
                height: 1.63,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
        const SizedBox(height: AppSpacing.s24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bgInverse,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'LANJUT',
              style: AppTextStyles.labelXl15.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.38,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

