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

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;
  final String? cartItemId;
  final int? cartItemQty;
  final List<String>? variantLabels;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onQuickAdd,
    required this.isFavourite,
    required this.onToggleFavourite,
    this.cartItemId,
    this.cartItemQty,
    this.variantLabels,
  });

  @override
  Widget build(BuildContext context) {
    final qty = cartItemQty ??
        context.select<CartProvider, int>((cart) => cart.items
            .where((i) => i.product.id == product.id)
            .fold(0, (sum, i) => sum + i.quantity));

    final hasVariants = product.hasVariants;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product image
              Image.network(
                product.image,
                height: 100,
                width: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 100,
                  width: 90,
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: 40,
                    color: AppColors.backgroundDark,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 100,
                    width: 90,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name + favourite
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, top: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AutoScrollTicker(
                                text: product.name.toTitleCase(),
                                style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.backgroundDark,
                                    fontSize: 15)),
                          ),
                          Consumer<FavouritesProvider>(
                            builder: (context, favProv, _) {
                              final isFav = favProv.isFavourite(product.id);
                              return GestureDetector(
                                onTap: () => favProv.toggle(product.id),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: AppColors.primaryRed,
                                    size: 16,
                                    key: ValueKey(isFav),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // ── Variant chip below name ──────────────
                    if (variantLabels != null && variantLabels!.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: variantLabels!.map((label) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withValues(alpha: .9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: AppColors.primaryRed
                                      .withValues(alpha: .8)),
                            ),
                            child: Text(
                              label,
                              style: AppTextStyles.bodySmallWhite.copyWith(
                                color: AppColors.backgroundLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 2,
                      )
                    ],
                    // ─────────────────────────────────────────

                    // Description only if present
                    product.description.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Column(
                              children: [
                                Text(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    product.description.toTitleCase(),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.backgroundDark,
                                        fontSize: 10)),
                                SizedBox(
                                  height: 2,
                                )
                              ],
                            ),
                          )
                        : Text("No Description",
                            style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.backgroundDark,
                                fontSize: 10)),

                    // Price + Add button always pinned to bottom
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rs ${product.displayPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.backgroundDark,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          AddCounter(
                            qty: qty,
                            productId: product.id,
                            hasVariants: hasVariants,
                            onAdd: onQuickAdd,
                            onNavigate: onTap,
                            cartItemId: cartItemId,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCounter extends StatelessWidget {
  final int qty;
  final String productId;
  final bool hasVariants;
  final VoidCallback onAdd;
  final VoidCallback onNavigate;
  final String? cartItemId;

  const AddCounter({
    super.key,
    required this.qty,
    required this.productId,
    required this.hasVariants,
    required this.onAdd,
    required this.onNavigate,
    this.cartItemId,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = qty > 0;
    final isCartPage = cartItemId != null;
    final VoidCallback addAction =
        (!isCartPage && hasVariants) ? onNavigate : onAdd;

    final bool showExpanded = hasItems && (isCartPage || !hasVariants);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      height: 32,
      width: showExpanded ? 88 : 32,
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334A3728),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: showExpanded
          ? Row(
              children: [
                // − decrement
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isCartPage) {
                        context
                            .read<CartProvider>()
                            .updateCartItem(cartItemId!, qty - 1);
                      } else {
                        context
                            .read<CartProvider>()
                            .updateById(productId, qty - 1);
                      }
                    },
                    child: Icon(Icons.remove_rounded,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 14),
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
                      fontSize: 13,
                    ),
                  ),
                ),
                // + increment
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isCartPage) {
                        context
                            .read<CartProvider>()
                            .updateCartItem(cartItemId!, qty + 1);
                      } else {
                        onAdd();
                      }
                    },
                    child: Icon(Icons.add_rounded,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 14),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: addAction,
              child: Icon(Icons.add_rounded,
                  color: Theme.of(context).colorScheme.onSecondary, size: 18),
            ),
    );
  }
}
