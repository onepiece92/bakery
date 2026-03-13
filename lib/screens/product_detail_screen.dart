import 'package:bakery_flutter/extensions/string_casing_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import 'package:bakery_flutter/models/product/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../components/bakery_back_button.dart';
import '../../components/product_bottom_cta.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 0;
  int _activeImage = 0;
  final Map<String, String> _selectedOptionValues = {};
  final Set<String> _selectedAddonIds = {};

  final TextEditingController _instructionsCtrl = TextEditingController();
  VariantItem? get _matchedVariant {
    final variants = widget.product.variants;
    if (variants == null) return null;
    if (_selectedOptionValues.length != variants.options.length) return null;

    final selectedValues = variants.options
        .map((o) => _selectedOptionValues[o.title])
        .whereType<String>()
        .toList();

    try {
      return variants.variantItems.firstWhere(
        (item) =>
            item.optionValues.length == selectedValues.length &&
            item.optionValues.every((v) => selectedValues.contains(v)),
      );
    } catch (_) {
      return null;
    }
  }

  List<Addon> get _selectedAddons => widget.product.addons
      .where((a) => _selectedAddonIds.contains(a.id))
      .toList();

  double get _addonTotal =>
      _selectedAddons.fold(0.0, (sum, a) => sum + a.price);

  double get _unitPrice =>
      (_matchedVariant?.price ?? widget.product.displayPrice) + _addonTotal;

  double get _totalPrice => _unitPrice * _quantity;

  @override
  void initState() {
    super.initState();

    final variants = widget.product.variants;
    if (variants != null) {
      for (final option in variants.options) {
        if (option.values.isNotEmpty) {
          _selectedOptionValues[option.title] = option.values.first;
        }
      }
    }

    // Sync quantity from cart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartItem = context
          .read<CartProvider>()
          .items
          .where((i) => i.product.id == widget.product.id)
          .firstOrNull;
      if (cartItem != null && mounted) {
        setState(() => _quantity = cartItem.quantity);
      }
    });
  }

  @override
  void dispose() {
    _instructionsCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavouritesProvider>();
    final isFav = favProv.isFavourite(widget.product.id);
    final variants = widget.product.variants;
    final addons = widget.product.addons;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                scrolledUnderElevation: 0,
                elevation: 0,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: BakeryBackButton(),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => favProv.toggle(widget.product.id),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      alignment: Alignment.center,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav
                            ? Colors.redAccent
                            : Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.share_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: Theme.of(context)
                          .extension<AppThemeExtension>()
                          ?.heroGradient,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          widget.product.image,
                          width: double.infinity,
                          // height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image_rounded,
                            size: 40,
                            // color: AppColors.softBrown,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                        // Gallery dots
                        // Positioned(
                        //   bottom: 18,
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: List.generate(3, (i) {
                        //       return GestureDetector(
                        //         onTap: () => setState(() => _activeImage = i),
                        //         child: AnimatedContainer(
                        //           duration: const Duration(milliseconds: 300),
                        //           margin:
                        //               const EdgeInsets.symmetric(horizontal: 3),
                        //           width: _activeImage == i ? 20 : 7,
                        //           height: 7,
                        //           decoration: BoxDecoration(
                        //             color: _activeImage == i
                        //                 ? Theme.of(context).colorScheme.surface
                        //                 : Theme.of(context)
                        //                     .colorScheme
                        //                     .surface
                        //                     .withValues(alpha: 0.45),
                        //             borderRadius: BorderRadius.circular(4),
                        //           ),
                        //         ),
                        //       );
                        //     }),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + category
                      Text(widget.product.name.toTitleCase(),
                          style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 6),
                      // Text(widget.product.categories,
                      //     style: Theme.of(context).textTheme.bodySmall),
                      // const SizedBox(height: 12),

                      // Description
                      Text(
                        widget.product.description.toTitleCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            height: 1.6),
                      ),
                      const SizedBox(height: 6),

                      // Tags
                      // if (widget.product.tags.isNotEmpty) ...[
                      //   Wrap(
                      //     spacing: 8,
                      //     runSpacing: 6,
                      //     children: widget.product.tags.map((tag) {
                      //       final isGood = tag.contains('Gluten') ||
                      //           tag.contains('Vegan') ||
                      //           tag.contains('Organic');
                      //       return Container(
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 12, vertical: 5),
                      //         decoration: BoxDecoration(
                      //           color: isGood
                      //               ? Theme.of(context)
                      //                   .colorScheme
                      //                   .secondaryContainer
                      //               : Theme.of(context)
                      //                   .colorScheme
                      //                   .errorContainer,
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         child: Text(
                      //           tag,
                      //           style: Theme.of(context)
                      //               .textTheme
                      //               .labelSmall
                      //               ?.copyWith(
                      //                 color: isGood
                      //                     ? Theme.of(context)
                      //                         .colorScheme
                      //                         .onSecondaryContainer
                      //                     : Theme.of(context)
                      //                         .colorScheme
                      //                         .onErrorContainer,
                      //                 fontSize: 12,
                      //               ),
                      //         ),
                      //       );
                      //     }).toList(),
                      //   ),
                      //   const SizedBox(height: 24),
                      // ],

                      // ── Variants ─────────────────────────────
                      if (variants != null && variants.options.isNotEmpty) ...[
                        ...variants.options.map((option) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(title: option.title),
                              const SizedBox(height: 12),
                              ...option.values.map((value) {
                                final isActive =
                                    _selectedOptionValues[option.title] ==
                                        value;
                                final matchingItem =
                                    variants.variantItems.firstWhere(
                                  (item) => item.optionValues.contains(value),
                                  orElse: () => variants.variantItems.first,
                                );

                                return _OptionItem(
                                  name: value,
                                  price: matchingItem.price,
                                  isActive: isActive,
                                  onTap: () => setState(() =>
                                      _selectedOptionValues[option.title] =
                                          value),
                                );
                              }),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                      ],

                      // ── Addons ────────────────────────────────
                      if (addons.isNotEmpty) ...[
                        _SectionHeader(title: 'Add-ons'),
                        const SizedBox(height: 12),
                        ...addons.map((addon) {
                          final isActive = _selectedAddonIds.contains(addon.id);
                          return _OptionItem(
                            name: addon.name,
                            price: addon.price,
                            isActive: isActive,
                            onTap: () => setState(() {
                              if (isActive) {
                                _selectedAddonIds.remove(addon.id);
                              } else {
                                _selectedAddonIds.add(addon.id);
                              }
                            }),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // ── Special Instructions ──────────────────
                      // Text(
                      //   'Special Instructions',
                      //   style: Theme.of(context)
                      //       .textTheme
                      //       .titleMedium
                      //       ?.copyWith(
                      //         fontWeight: FontWeight.w700,
                      //         fontSize: 18,
                      //         color: Theme.of(context).colorScheme.onSurface,
                      //       ),
                      // ),
                      // const SizedBox(height: 16),
                      // TextField(
                      //   controller: _instructionsCtrl,
                      //   maxLines: 4,
                      //   style: Theme.of(context).textTheme.bodyLarge,
                      //   decoration: InputDecoration(
                      //     hintText: 'E.g. No onions, sauce on the side...',
                      //     hintStyle:
                      //         Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //               color: Theme.of(context)
                      //                   .colorScheme
                      //                   .onSurfaceVariant
                      //                   .withValues(alpha: 0.6),
                      //             ),
                      //     filled: true,
                      //     fillColor: Theme.of(context).cardColor,
                      //     contentPadding: const EdgeInsets.all(20),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(24),
                      //       borderSide: BorderSide(
                      //           color: Theme.of(context).dividerColor),
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(24),
                      //       borderSide: BorderSide(
                      //           color: Theme.of(context).dividerColor),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(24),
                      //       borderSide: BorderSide(
                      //           color: Theme.of(context)
                      //               .colorScheme
                      //               .primary
                      //               .withValues(alpha: 0.5)),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ProductBottomCta(
            quantity: _quantity,
            totalPrice: _totalPrice,
            onDecrement: () {
              if (_quantity > 0) {
                setState(() => _quantity--);
                final cart = context.read<CartProvider>();
                if (cart.contains(widget.product)) {
                  cart.updateById(widget.product.id, _quantity);
                }
              }
            },
            onIncrement: () {
              setState(() => _quantity++);
              final cart = context.read<CartProvider>();
              if (cart.contains(widget.product)) {
                cart.updateByLineKey(
                  '${widget.product.id}__${_matchedVariant?.id ?? 'no_variant'}',
                  _quantity,
                );
              } else {
                cart.addProduct(
                  widget.product,
                  quantity: _quantity,
                  variant: _matchedVariant,
                  addons: _selectedAddons,
                );
              }
            },
            onCheckout: () {
              if (_quantity > 0) {
                final cart = context.read<CartProvider>();
                if (!cart.contains(widget.product)) {
                  cart.addProduct(
                    widget.product,
                    quantity: _quantity,
                    variant: _matchedVariant,
                    addons: _selectedAddons,
                  );
                }
                context.push('/cart');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select at least 1 item')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Private Helper Widgets ────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String name;
  final double price;
  final bool isActive;
  final VoidCallback onTap;

  const _OptionItem({
    required this.name,
    required this.price,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).unselectedWidgetColor,
                  width: isActive ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name.toTitleCase(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            Text(
              price == 0
                  ? 'Free'
                  : price > 0
                      ? price.toStringAsFixed(2)
                      : price.abs().toStringAsFixed(2),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
