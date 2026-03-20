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

import 'package:bakery_flutter/extensions/string_casing_extension.dart';
import 'package:bakery_flutter/extensions/ticker.dart';
import 'package:bakery_flutter/models/product/product_model.dart';
import 'package:bakery_flutter/providers/cart_provider.dart';
import 'package:bakery_flutter/providers/favourites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CartCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;
  final String? cartItemId;
  final int? cartItemQty;
  final List<String>? variantLabels;
    final double? unitPrice;

  const CartCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onQuickAdd,
    required this.isFavourite,
    required this.onToggleFavourite,
    this.cartItemId,
    this.cartItemQty,
    this.variantLabels, this.unitPrice,
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
              /// Product Image
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

              /// Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Name + Favourite
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, top: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AutoScrollTicker(
                              text: product.name.toTitleCase(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.backgroundDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Consumer<FavouritesProvider>(
                          //   builder: (context, favProv, _) {
                          //     final isFav = favProv.isFavourite(product.id);
                          //     return GestureDetector(
                          //       onTap: () => favProv.toggle(product.id),
                          //       child: AnimatedSwitcher(
                          //         duration: const Duration(milliseconds: 200),
                          //         child: Icon(
                          //           isFav
                          //               ? Icons.favorite_rounded
                          //               : Icons.favorite_border_rounded,
                          //           color: AppColors.primaryRed,
                          //           size: 16,
                          //           key: ValueKey(isFav),
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                    ),

                    /// Variant Labels (Same as ProductCard)
                    if (variantLabels != null && variantLabels!.isNotEmpty) ...[
                      const SizedBox(height: 2),
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
                                    .withValues(alpha: .8),
                              ),
                            ),
                            child: Text(
                              label.toCapitalized(),
                              style: AppTextStyles.bodySmallWhite.copyWith(
                                color: AppColors.backgroundLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 4),
                    ],

                    /// Description
                    product.description.isNotEmpty
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Text(
                                  product.description.toTitleCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                          )
                        : Text(
                            "No Description",
                            style: AppTextStyles.labelSmall,
                          ),

                    /// Price + Counter
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                         Text(
  'Rs ${(unitPrice ?? product.displayPrice).toStringAsFixed(2)}', 
  style: AppTextStyles.price,
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

// import 'package:bakery_flutter/extensions/string_casing_extension.dart';
// import 'package:bakery_flutter/models/product/product_model.dart';
// import 'package:bakery_flutter/providers/favourites_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_decorations.dart';
// import '../theme/app_text_styles.dart';
// import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap; // Navigate to detail (variants or manage)
  final VoidCallback onQuickAdd; // Direct add 1 (no variants)
  final String? cartItemId;
  final int? cartItemQty;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onQuickAdd,
    this.cartItemId,
    this.cartItemQty,
  });

  @override
  Widget build(BuildContext context) {
    final qty = cartItemQty ??
        context.select<CartProvider, int>((cart) => cart.items
            .where((i) => i.product.id == product.id)
            .fold(0, (sum, i) => sum + i.quantity));

    final hasVariants = product.hasVariants;

    return GestureDetector(
      onTap: onTap, // Card tap → detail page
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hero image + favourite overlay
            Stack(
              children: [
                Image.network(
                  product.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.broken_image_rounded,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),

                // Favourite button (top-right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Consumer<FavouritesProvider>(
                    builder: (context, favProv, _) {
                      final isFav = favProv.isFavourite(product.id);
                      return GestureDetector(
                        onTap: () => favProv.toggle(product.id),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 24,
                              key: ValueKey(isFav),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Content area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    product.name.toTitleCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    
                    product.description.isNotEmpty
                        ? product.description.toTitleCase()
                        : "No Description",

                        

                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                      
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Price + AddCounter (this is the interactive part)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rs ${product.displayPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5722),
                        ),
                      ),
                      AddCounter(
                        qty: qty,
                        productId: product.id,
                        hasVariants: hasVariants,
                        onAdd: () {
                          // When user taps + on AddCounter and no variants
                          onQuickAdd();
                        },
                        onNavigate:
                            onTap, // When user taps the counter area and has variants
                        cartItemId: cartItemId,
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
      height: 40,
      width: showExpanded ? 90 : 80, 
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(36),
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
                        size: 20),
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
                        size: 20),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: addAction,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}