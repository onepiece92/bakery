import 'package:bakery_flutter/extensions/string_casing_extension.dart';
import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:bakery_flutter/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final Map<String, String> _selectedOptionValues = {};
  final Set<String> _selectedAddonIds = {};

  final TextEditingController _instructionsCtrl = TextEditingController();

  // ── Computed helpers ──────────────────────────────────────────

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

  // ── Lifecycle ─────────────────────────────────────────────────

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

    const double imageHeight = 320.0;
    const double curveRadius = 28.0;

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500;
      final maxWidth = isWide ? 500.0 : double.infinity;

      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Scaffold(
              backgroundColor: context.theme.scaffoldBackgroundColor,
              body: Stack(
                children: [
                  // ── 1. Fixed image pinned behind everything ────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: imageHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: context.appTheme.heroGradient,
                      ),
                      child: Image.network(
                        widget.product.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            size: 48,
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      ),
                    ),
                  ),

                  SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: imageHeight - curveRadius),
                          Container(
                            decoration: BoxDecoration(
                              color: context.theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(curveRadius),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 10, 12, 140),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Name ────────────────────────
                                Text(
                                  widget.product.name.toTitleCase(),
                                  style: context.text.displayMedium?.copyWith(
                                      color: AppColors.backgroundDark),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Rs ${(_matchedVariant?.price ?? widget.product.displayPrice).toStringAsFixed(2)}',
                                  style: context.text.titleLarge?.copyWith(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20),
                                ),
                                const SizedBox(height: 10),

                                  Visibility(
                                visible: widget.product.description.isNotEmpty,
                                maintainSize: false,
                                maintainAnimation: false,
                                maintainState: false,
                                child: Text(
                                  widget.product.description.toTitleCase(),
                                  style: context.text.bodyMedium?.copyWith(
                                    color: context.text.bodySmall?.color,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                                // const SizedBox(height: 28),

                                if (variants != null &&
                                    variants.options.isNotEmpty) ...[
                                  ...variants.options.map((option) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _SectionHeader(
                                          title: option.title.toTitleCase(),
                                          isRequired: true,
                                        ),
                                        const SizedBox(height: 12),
                                        ...option.values.map((value) {
                                          final isActive =
                                              _selectedOptionValues[
                                                      option.title] ==
                                                  value;
                                          final matchingItem =
                                              variants.variantItems.firstWhere(
                                            (item) => item.optionValues
                                                .contains(value),
                                            orElse: () =>
                                                variants.variantItems.first,
                                          );

                                          return _OptionItem(
                                            name: value,
                                            price: matchingItem.price,
                                            isActive: isActive,
                                            onTap: () => setState(() =>
                                                _selectedOptionValues[
                                                    option.title] = value),
                                          );
                                        }),
                                        // const SizedBox(height: 8),
                                      ],
                                    );
                                  }),
                                ],

                                if (addons.isNotEmpty) ...[
                                  const _SectionHeader(
                                    title: 'Add-ons',
                                    isRequired: false,
                                  ),
                                  const SizedBox(height: 12),
                                  ...addons.map((addon) {
                                    final isActive =
                                        _selectedAddonIds.contains(addon.id);
                                    return _OptionItem(
                                      name: addon.name,
                                      price: addon.price,
                                      isActive: isActive,
                                      isCheckbox: true,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _HeroButton(
                            child: const BakeryBackButton(),
                          ),
                          Row(
                            children: [
                              _HeroButton(
                                onTap: () => favProv.toggle(widget.product.id),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isFav ? Colors.redAccent : Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Share
                              // _HeroButton(
                              //   child: const Icon(
                              //     Icons.share_outlined,
                              //     color: Colors.white,
                              //     size: 20,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ProductBottomCta(
                      quantity: _quantity,
                      totalPrice: _totalPrice,
                      onDecrement: () {
                        if (_quantity > 0) setState(() => _quantity--);
                      },
                      onIncrement: () {
                        setState(() => _quantity++);
                      },
                      onCheckout: () {
                        if (_quantity > 0) {
                          context.read<CartProvider>().addProduct(
                                widget.product,
                                quantity: _quantity,
                                variant: _matchedVariant,
                                addons: _selectedAddons,
                              );
                          context.push('/cart-screen');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least 1 item'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _HeroButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HeroButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isRequired;

  const _SectionHeader({
    required this.title,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: context.colors.onSurface,
          ),
        ),
        if (isRequired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Required',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          )
        else
          Text(
            'Optional',
            style: TextStyle(
              fontSize: 13,
              color: context.colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String name;
  final double price;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCheckbox;

  const _OptionItem({
    required this.name,
    required this.price,
    required this.isActive,
    required this.onTap,
    this.isCheckbox = false,
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
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isActive ? context.colors.primary : context.theme.dividerColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            // if (isCheckbox)
            //   Icon(
            //     isActive ? Icons.check_circle : Icons.radio_button_off,
            //     color: isActive
            //         ? context.colors.primary
            //         : context.theme.unselectedWidgetColor,
            //     size: 22,
            //   )
            // else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? context.colors.primary
                        : context.theme.unselectedWidgetColor,
                    width: isActive ? 6 : 1.5,
                  ),
                ),
              ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                name.toTitleCase(),
                style: context.text.bodyLarge?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            // Price
            Text(
              price == 0
                  ? 'Free'
                  : price > 0
                      ? 'Rs ${price.toStringAsFixed(2)}'
                      : 'Rs ${price.abs().toStringAsFixed(2)}',
              style: context.text.bodyMedium?.copyWith(
                color: isActive
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
