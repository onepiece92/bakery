import 'package:bakery_flutter/extensions/string_casing_extension.dart';
import 'package:bakery_flutter/extensions/ticker.dart';
import 'package:bakery_flutter/models/product/product_model.dart';
import 'package:bakery_flutter/providers/favourites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';
import '../providers/cart_provider.dart';

/// Grid-view product card with live qty counter on the add button.
class GridProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;

  const GridProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onQuickAdd,
    required this.isFavourite,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final qty = context.select<CartProvider, int>((cart) => cart.items
        .where((i) => i.product.id == product.id)
        .fold(0, (sum, i) => sum + i.quantity));

    final hasVariants = product.hasVariants;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image fills all remaining space after bottom section ──────
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 36,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    ),
                  ),

                  // Favourite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<FavouritesProvider>(
                      builder: (context, favProv, _) {
                        final isFav = favProv.isFavourite(product.id);
                        return GestureDetector(
                          onTap: () => favProv.toggle(product.id),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(
                                  AppDecorations.radiusXS),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: AppColors.primaryRed,
                              size: 15,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AutoScrollTicker(
                      // text: "DSJVNJFVNKDFNVKDFNVKDNVKDFNV",
                      text: product.name.toTitleCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.displayPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.price,
                          overflow: TextOverflow
                              .ellipsis, // shrinks with ... if needed
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _GridAddCounter(
                        qty: qty,
                        productId: product.id,
                        hasVariants: hasVariants,
                        onAdd: onQuickAdd,
                        onNavigate: onTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridAddCounter extends StatelessWidget {
  final int qty;
  final String productId;
  final bool hasVariants;
  final VoidCallback onAdd;
  final VoidCallback onNavigate;

  const _GridAddCounter({
    required this.qty,
    required this.productId,
    required this.hasVariants,
    required this.onAdd,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = qty > 0;
    final VoidCallback addAction = hasVariants ? onNavigate : onAdd;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final expandedWidth = screenWidth > 400 ? 80.0 : 52.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          height: 28,
          width: (!hasVariants && hasItems) ? expandedWidth : 28,
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(AppDecorations.radiusS),
          ),
          clipBehavior: Clip.hardEdge,
          child: (!hasVariants && hasItems)
              ? Row(
                  children: [
                    // − decrement
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context
                            .read<CartProvider>()
                            .updateById(productId, qty - 1),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Icon(Icons.remove_rounded,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 12),
                        ),
                      ),
                    ),
                    // Animated count
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Text(
                        '$qty',
                        key: ValueKey(qty),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // + increment
                    Expanded(
                      child: GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Icon(Icons.add_rounded,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 12),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: addAction,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Icon(Icons.add_rounded,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 16),
                  ),
                ),
        );
      },
    );
  }
}
