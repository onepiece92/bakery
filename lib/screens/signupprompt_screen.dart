import 'package:bakery_flutter/components/primary_button.dart';
import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:bakery_flutter/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SignupPromptScreen extends StatelessWidget {
  const SignupPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500;
      final maxWidth = isWide ? 500.0 : double.infinity;
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide.none,
              ),
            ),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/sign_in.json',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                      delegates: LottieDelegates(
                        values: [
                          // T-shirt red → AppColors.primary
                          ValueDelegate.color(
                            const ['**', 'Body', '**'],
                            value: AppColors.primaryRed,
                          ),
                          // Phone popup red → AppColors.primary
                          ValueDelegate.color(
                            const ['**', 'Phone', '**'],
                            value: AppColors.primaryRed,
                          ),
                          // Chart red elements → AppColors.primary
                          ValueDelegate.color(
                            const ['**', 'Layer 20 Outlines', '**'],
                            value: AppColors.primaryRed,
                          ),
                          ValueDelegate.color(
                            const ['**', 'Layer 18 Outlines', 'Group 2', '**'],
                            value: AppColors.primaryRed,
                          ),
                        ],
                      ),
                    ),
                    PrimaryButton(
                      label: 'Create Account',
                      onTap: () => context.push('/signup'),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Login',
                      onTap: () => context.go('/profile/login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
