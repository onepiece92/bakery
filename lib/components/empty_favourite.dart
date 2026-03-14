import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../components/browse_menu_button.dart';

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
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),

            // ── Headline ──────────────────────────────────────────────
            Text(
              'No favourites yet',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // ── Subtitle ──────────────────────────────────────────────
            Text(
              'Items you love will show up here.\nTap ♡ on any product to save it.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // // ── Browse CTA ────────────────────────────────────────────
            // const BrowseMenuButton(),
          ],
        ),
      ),
    );
  }
}
