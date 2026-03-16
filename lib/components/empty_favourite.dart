import 'package:bakery_flutter/theme/app_colors.dart';
import 'package:bakery_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyFavourites extends StatelessWidget {
  const EmptyFavourites({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Lottie animation ──────────────────────────────────────
            Flexible(
  child: Lottie.asset(
    'assets/animations/empty_fav.json',
    width: 250,
    height: 150,
    repeat: true,
    fit: BoxFit.contain,
    delegates: LottieDelegates(
      values: [

        // Fill
        ValueDelegate.color(
          const ['**', 'Fill 1'],
          value: AppColors.primaryRed,
        ),

        // All strokes
        ValueDelegate.strokeColor(
          const ['**', 'Stroke 1'],
          value: AppColors.primaryRed,
        ),

      ],
    ),
  ),
),
            // const SizedBox(height: 16),

            // ── Headline ──────────────────────────────────────────────
            Text(
              'No favourites yet',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // // ── Browse CTA ────────────────────────────────────────────
            // const BrowseMenuButton(),
          ],
        ),
      ),
    );
  }
}
