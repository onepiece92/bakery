import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import './browse_menu_button.dart';

class EmptyCartView extends StatelessWidget {
  final VoidCallback? onBack;

  const EmptyCartView({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Lottie.asset(
              'assets/animations/empty_cart.json',
              width: 250,
              repeat: true,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.shopping_basket_outlined,
                    size: 100, color: Colors.grey);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Looks like you haven't added anything yet",
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          BrowseMenuButton(onTap: onBack),
        ],
      ),
    );
  }
}
