import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CommingSoon extends StatelessWidget {
  const CommingSoon({
    super.key,
    this.title = 'Coming Soon',
    this.subtitle = 'We\'re working hard to bring you something amazing. Stay tuned!',
    this.onNotify,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onNotify;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Lottie Animation
        Lottie.asset(
          'assets/animations/comming_soon.json',
          width: 220,
          height: 220,
          fit: BoxFit.contain,
          repeat: true,
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 10),

        // Subtitle
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
          ),
        ),

        if (onNotify != null) ...[
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNotify,
              child: const Text('Notify Me'),
            ),
          ),
        ],
      ],
    );
  }
}