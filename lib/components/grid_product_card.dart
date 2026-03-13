import 'package:bakery_flutter/extensions/string_casing_extension.dart';
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
          children: [
            // ── Image area ──────────────────────────────────────────────────
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: AppDecorations.productImage,
                  alignment: Alignment.center,
                  child: Image.network(
                    product.image,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_rounded,
                      size: 36,
                      color: AppColors.softBrown,
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
                            borderRadius:
                                BorderRadius.circular(AppDecorations.radiusXS),
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

            // ── Info + counter ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.toTitleCase(),
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkBrown,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(product.description.toTitleCase(),
                      style: AppTextStyles.labelSmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.displayPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.price,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // ── Add / counter button ─────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
/// Compact "+" for the grid card.
/// If [hasVariants] is true, tapping "+" always navigates to the detail screen
/// instead of directly adding to cart.
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

    // If variants exist, always navigate — never expand the counter
    final VoidCallback addAction = hasVariants ? onNavigate : onAdd;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      height: 28,
      width: (!hasVariants && hasItems) ? 80 : 28,
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
                    child: Icon(Icons.remove_rounded,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 12),
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
                    child: Icon(Icons.add_rounded,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 12),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: addAction,
              child: Icon(Icons.add_rounded,
                  color: Theme.of(context).colorScheme.onSecondary, size: 16),
            ),
    );
  }
}
