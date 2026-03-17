import 'package:bakery_flutter/extensions/string_casing_extension.dart';
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

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavouritesProvider>();
    final isFav = favProv.isFavourite(widget.product.id);
    final variants = widget.product.variants;
    final addons = widget.product.addons;

    final basePrice = _matchedVariant?.price ?? widget.product.displayPrice;

    const double imageHeight = 380.0;
    const double curveRadius = 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Fixed image background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(curveRadius),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.product.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_rounded,
                      size: 60,
                      color: Colors.white70,
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2));
                    },
                  ),
                ],
              ),
            ),
          ),

          // Top action buttons overlay

          // Scrollable content that overlaps and slides over the image
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Spacer to start content inside the curve
                SizedBox(height: imageHeight - curveRadius),

                // Content card with rounded top corners
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(curveRadius)),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(
                        20, 28, 20, 180), // extra bottom padding for CTA
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Price row
                        Text(
                          widget.product.name.toTitleCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '\$${basePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5722),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        if (widget.product.description.isNotEmpty)
                          Text(
                            widget.product.description.toTitleCase(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Variants / Options
                        if (variants != null &&
                            variants.options.isNotEmpty) ...[
                          ...variants.options.map((option) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(option.title,
                                    isRequired: true),
                                const SizedBox(height: 16),
                                ...option.values.map((value) {
                                  final isActive =
                                      _selectedOptionValues[option.title] ==
                                          value;
                                  final matchingItem =
                                      variants.variantItems.firstWhere(
                                    (item) => item.optionValues.contains(value),
                                    orElse: () => variants.variantItems.first,
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildSelectableTile(
                                      label: value,
                                      price: matchingItem.price,
                                      selected: isActive,
                                      onTap: () => setState(() {
                                        _selectedOptionValues[option.title] =
                                            value;
                                      }),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 24),
                              ],
                            );
                          }),
                        ],

                        // Add-ons
                        if (addons.isNotEmpty) ...[
                          _buildSectionHeader("Add-ons", isRequired: false),
                          const SizedBox(height: 16),
                          ...addons.map((addon) {
                            final isActive =
                                _selectedAddonIds.contains(addon.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSelectableTile(
                                label: addon.name,
                                price: addon.price,
                                selected: isActive,
                                onTap: () => setState(() {
                                  if (isActive) {
                                    _selectedAddonIds.remove(addon.id);
                                  } else {
                                    _selectedAddonIds.add(addon.id);
                                  }
                                }),
                                isCheckbox: true,
                              ),
                            );
                          }),
                          const SizedBox(height: 32),
                        ],

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating bottom CTA
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
                GoRouter.of(context).go('/cart');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select at least 1 item')),
                );
              }
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: 44,
                      width: 44,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const BakeryBackButton(
                        color: Colors.white,
                      )),
                  GestureDetector(
                    onTap: () => favProv.toggle(widget.product.id),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required bool isRequired}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isRequired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "REQUIRED",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5722),
              ),
            ),
          )
        else
          Text(
            "Optional",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }

  Widget _buildSelectableTile({
    required String label,
    required double price,
    required bool selected,
    required VoidCallback onTap,
    bool isCheckbox = false,
  }) {
    final displayPrice = price == 0
        ? "Free"
        : price > 0
            ? "+${price.toStringAsFixed(2)}"
            : price.toStringAsFixed(2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selected ? const Color(0xFFFF5722) : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                isCheckbox
                    ? (selected ? Icons.check_circle : Icons.radio_button_off)
                    : (selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off),
                color:
                    selected ? const Color(0xFFFF5722) : Colors.grey.shade400,
                size: 26,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label.toTitleCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                displayPrice,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: price == 0
                      ? Colors.green.shade700
                      : const Color(0xFFFF5722),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
