import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:foundit/theme/app_colors.dart';
import 'package:foundit/theme/app_text_styles.dart';
import 'package:foundit/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:foundit/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double sheetHeight = math
              .max(math.min(constraints.maxHeight * 0.56, 620.0), 340.0)
              .clamp(0.0, constraints.maxHeight)
              .toDouble();
          return Column(
            children: [
              Expanded(child: _buildTopSection()),
              SizedBox(height: sheetHeight, child: _buildBottomSheet(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopSection() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: AppSpacing.s32,
          left: AppSpacing.s20,
          right: AppSpacing.s20,
          bottom: AppSpacing.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Temukan atau Laporkan Barangmu',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleL16.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            _buildFloatingIllustration(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIllustration() {
    return SizedBox(
      height: 232,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 8,
            top: 16,
            child: _buildSoftCircle(72, const Color(0xFFE2E7FF), 0.55),
          ),
          Positioned(
            right: 8,
            bottom: 16,
            child: _buildSoftCircle(88, const Color(0xFFD3E4FE), 0.5),
          ),
          Container(
            width: 300,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          Align(
            alignment: const Alignment(-0.78, -0.92),
            child: _buildIconTile(
              icon: Icons.search,
              background: const Color(0xFFDBE1FF),
            ),
          ),
          Align(
            alignment: const Alignment(0.78, -0.92),
            child: _buildIconTile(
              icon: Icons.photo_outlined,
              background: const Color(0xFFD5E4F8),
            ),
          ),
          Align(
            alignment: const Alignment(-0.72, 0.95),
            child: _buildIconTile(
              icon: Icons.verified_rounded,
              background: const Color(0xFFE2E7FF),
              size: 18,
            ),
          ),
          Align(
            alignment: const Alignment(0.78, 0.95),
            child: _buildIconTile(
              icon: Icons.vpn_key_rounded,
              background: const Color(0xFFDAE2FD),
              size: 18,
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x330B1A30),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/icon-apps.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }

  Widget _buildIconTile({
    required IconData icon,
    required Color background,
    double size = 22,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0C000000),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(icon, size: size, color: AppColors.primaryPressed),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0B1A30),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 30,
            offset: Offset(0, -10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              Text(
                'Sign in to get started',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingL22.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Masuk untuk membantu sesama',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyL14.copyWith(
                  color: const Color(0xCCBFDBFE),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              _buildSignInButton(
                label: 'Sign in with Google',
                backgroundColor: Colors.white,
                textColor: const Color(0xFF1E293B),
                logoPath: 'assets/images/google-logo.png',
                onPressed: () async {
                  final AuthProvider auth = context.read<AuthProvider>();
                  final bool ok = await auth.signInWithGoogle();
                  if (!context.mounted) return;
                  if (ok) {
                    Navigator.pushNamedAndRemoveUntil(
                      context, '/dashboard', (route) => false);
                  } else if (auth.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(auth.error!)));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              _buildSignInButton(
                label: 'Sign in with Apple',
                backgroundColor: AppColors.primary,
                textColor: const Color.fromARGB(255, 255, 255, 255),
                logoPath: 'assets/images/apple-logo.png',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sign in with Apple belum tersedia (membutuhkan akun developer berbayar).',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Dengan masuk, Anda menyetujui ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const TextSpan(
                        text: 'Ketentuan Layanan',
                        style: TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 12,
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: ' & ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const TextSpan(
                        text: 'Kebijakan Privasi',
                        style: TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 12,
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: ' FoundIt.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required String logoPath,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(logoPath, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.labelXl15.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

