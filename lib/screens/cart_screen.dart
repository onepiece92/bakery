import 'package:bakery_flutter/models/cart_item.dart';
import 'package:bakery_flutter/models/services_model.dart';
import 'package:bakery_flutter/providers/order_provider.dart';
import 'package:bakery_flutter/providers/table_request_provider.dart';
import 'package:bakery_flutter/services/hive_services/order_hive_services.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../components/primary_button.dart';
import '../../components/product_card.dart';
import '../../providers/favourites_provider.dart';
import '../../components/empty_cart_view.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with WidgetsBindingObserver {
  final Set<String> _expandedNoteKeys = {};
  final Map<String, TextEditingController> _noteControllers = {};
  bool _isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    final isOpen = bottomInset > 0;
    if (isOpen != _isKeyboardOpen) {
      setState(() => _isKeyboardOpen = isOpen);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleNote(CartItem item) {
    final key = item.cartItemId;
    final cart = context.read<CartProvider>();

    setState(() {
      if (_expandedNoteKeys.contains(key)) {
        final text = _noteControllers[key]?.text.trim() ?? '';
        cart.setCartItemNote(key, text.isEmpty ? null : text);
        _expandedNoteKeys.remove(key);
        _noteControllers[key]?.dispose();
        _noteControllers.remove(key);
      } else {
        _expandedNoteKeys.add(key);
        _noteControllers[key] = TextEditingController(text: item.note ?? '');
      }
    });
  }

  void _flushNotes(CartProvider cart) {
    for (final key in _expandedNoteKeys.toList()) {
      final text = _noteControllers[key]?.text.trim() ?? '';
      cart.setCartItemNote(key, text.isEmpty ? null : text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final favProv = context.watch<FavouritesProvider>();
    final productProv = context.watch<ProductProvider>();
    final isBusiness = LocalStorageService.instance.getIsBusinessSession();

    final cartIds = cart.items.map((i) => i.product.id).toSet();
    final suggestions = productProv.products
        .where((p) => !cartIds.contains(p.id))
        .take(4)
        .toList();

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500;
      final maxWidth = isWide ? 500.0 : double.infinity;
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border(
                // top: BorderSide(color: Colors.grey.shade300),
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide.none,
              ),
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: context.theme.scaffoldBackgroundColor,
              appBar: AppBar(
                scrolledUnderElevation: 0,
                elevation: 0,
               automaticallyImplyActions: true,
                title: const Text('Your Cart'),
                actions: [
                  if (cart.items.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Text(
                          '${cart.totalCount} item${cart.totalCount != 1 ? 's' : ''}',
                          style: context.text.bodySmall,
                        ),
                      ),
                    ),
                ],
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: cart.items.isEmpty
                              ? const EmptyCartView()
                              : ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                      24, 0, 24, 150),
                                  children: [
                                    ...cart.items.map((item) {
                                      final key = item.cartItemId;
                                      final isExpanded =
                                          _expandedNoteKeys.contains(key);
                                      final hasNote = item.note != null &&
                                          item.note!.isNotEmpty;

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: AnimatedSize(
                                          duration: const Duration(
                                              milliseconds: 250),
                                          curve: Curves.easeInOut,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ProductCard(
                                                product: item.product,
                                                onTap: () => context.push(
                                                    '/home/product',
                                                    extra: item.product),
                                                onQuickAdd: () => cart
                                                    .addProduct(item.product),
                                                isFavourite: favProv
                                                    .isFavourite(
                                                        item.product.id),
                                                onToggleFavourite: () =>
                                                    favProv.toggle(
                                                        item.product.id),
                                                cartItemId: item.cartItemId,
                                                cartItemQty: item.quantity,
                                              ),

                                              if (item.selectedAddons
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Wrap(
                                                  spacing: 6,
                                                  runSpacing: 6,
                                                  children: item.selectedAddons
                                                      .map((addon) {
                                                    return Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .terracotta
                                                            .withValues(
                                                                alpha: 0.06),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppDecorations
                                                                        .radiusCard),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .terracotta
                                                              .withValues(
                                                                  alpha: 0.2),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            '+ ${addon.name}',
                                                            style: context
                                                                .text.bodySmall
                                                                ?.copyWith(
                                                              color: AppColors
                                                                  .terracotta,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '\$${addon.price.toStringAsFixed(2)}',
                                                            style: context
                                                                .text.bodySmall
                                                                ?.copyWith(
                                                              color: AppColors
                                                                  .terracotta
                                                                  .withValues(
                                                                      alpha:
                                                                          0.7),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          GestureDetector(
                                                            onTap: () {
                                                              final updatedAddons = item
                                                                  .selectedAddons
                                                                  .where((a) =>
                                                                      a.id !=
                                                                      addon.id)
                                                                  .toList();
                                                              cart.updateAddons(
                                                                  item.cartItemId,
                                                                  updatedAddons);
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              size: 14,
                                                              color: AppColors
                                                                  .terracotta
                                                                  .withValues(
                                                                      alpha:
                                                                          0.7),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4, top: 6),
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _toggleNote(item),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isExpanded
                                                            ? Icons
                                                                .keyboard_arrow_up_rounded
                                                            : (hasNote
                                                                ? Icons
                                                                    .edit_note_rounded
                                                                : Icons.add),
                                                        size: 14,
                                                        color:
                                                            AppColors.terracotta,
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        isExpanded
                                                            ? 'Hide note'
                                                            : (hasNote
                                                                ? 'Edit note'
                                                                : 'Add note'),
                                                        style: context
                                                            .appTheme.caption
                                                            .copyWith(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .terracotta,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // ── Expanded note field ──────────────
                                              if (isExpanded) ...[
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      _noteControllers[key],
                                                  autofocus: true,
                                                  maxLines: 2,
                                                  maxLength: 200,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  style: context.text.bodyMedium
                                                      ?.copyWith(
                                                          color: AppColors
                                                              .backgroundDark),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        '',
                                                    hintStyle: context
                                                        .text.bodySmall
                                                        ?.copyWith(
                                                            color: AppColors
                                                                .textLight),
                                                    filled: true,
                                                    fillColor: context
                                                        .colors
                                                        .surfaceContainerLow
                                                        .withValues(alpha: 0.4),
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    isDense: true,
                                                    counterStyle: context
                                                        .appTheme.caption
                                                        .copyWith(fontSize: 10),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppDecorations
                                                                  .radiusCard),
                                                      borderSide: BorderSide(
                                                          color: AppColors
                                                              .backgroundDark
                                                              .withValues(
                                                                  alpha: 0.2)),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppDecorations
                                                                  .radiusCard),
                                                      borderSide: BorderSide(
                                                          color: AppColors
                                                              .backgroundDark
                                                              .withValues(
                                                                  alpha: 0.2)),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppDecorations
                                                                  .radiusCard),
                                                      borderSide: BorderSide(
                                                          color: AppColors
                                                              .terracotta,
                                                          width: 1.5),
                                                    ),
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                          Icons
                                                              .check_circle_rounded,
                                                          color: AppColors
                                                              .terracotta,
                                                          size: 20),
                                                      tooltip: 'Save note',
                                                      onPressed: () =>
                                                          _toggleNote(item),
                                                    ),
                                                  ),
                                                ),
                                              ],

                                              // ── Saved note display ───────────────
                                              if (!isExpanded && hasNote) ...[
                                                const SizedBox(height: 6),
                                                Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 7),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.terracotta
                                                        .withValues(alpha: 0.06),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppDecorations
                                                                .radiusCard),
                                                    border: Border.all(
                                                        color: AppColors
                                                            .terracotta
                                                            .withValues(
                                                                alpha: 0.15)),
                                                  ),
                                                  child: Text(
                                                    item.note!,
                                                    style: context.text.bodySmall
                                                        ?.copyWith(
                                                            color: AppColors
                                                                .terracotta),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }),

                                    // ── Price summary ────────────────────────────
                                    Card(
                                      color: context
                                          .colors.surfaceContainerLow
                                          .withValues(alpha: 0.5),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppDecorations.radiusCard),
                                        side: BorderSide(
                                          color: AppColors.backgroundDark
                                              .withValues(alpha: 0.05),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            _PriceSummaryRow(
                                                label: 'Subtotal',
                                                value: cart.subtotal),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              child: Divider(
                                                  height: 1,
                                                  color: AppColors.backgroundDark
                                                      .withValues(alpha: 0.1)),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Total',
                                                    style: context
                                                        .text.headlineMedium),
                                                Text(
                                                  '\$${cart.total.toStringAsFixed(2)}',
                                                  style: context
                                                      .appTheme.priceLarge
                                                      .copyWith(
                                                    color: AppColors.terracotta,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),

                    // ── Checkout button ──────────────────────────────────────────
                    if (cart.items.isNotEmpty && !_isKeyboardOpen)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Consumer<TableRequestProvider>(
                          builder: (context, tableReq, _) => PrimaryButton(
                            label: tableReq.isLoadingFood
                                ? 'Placing Order...'
                                : 'Checkout — \$${cart.total.toStringAsFixed(2)}',
                            onTap: tableReq.isLoadingFood
                                ? null
                                : () async {
                                    _flushNotes(cart);

                                    if (cart.items.isEmpty) return;

                                    final orderProv =
                                        context.read<OrderProvider>();

                                    final foodItems =
                                        cart.items.map((item) {
                                      return FoodItemRequest(
                                        product: item.product.id,
                                        quantity: item.quantity,
                                        note: item.note,
                                        variant: item.selectedVariant?.id,
                                        addons: item.selectedAddons
                                            .map((a) => FoodAddonRequest(
                                                addonId: a.id, quantity: 1))
                                            .toList(),
                                      );
                                    }).toList();

                                    await tableReq.requestFood(
                                      businessId: LocalStorageService.instance
                                              .getBusinessId() ??
                                          '',
                                      foodItems: foodItems,
                                    );
                                      await orderProv.placeOrder(
                                        items: cart.items.toList(),
                                        subtotal: cart.subtotal,
                                        isBusinessOrder: isBusiness,
                                      );

                                    if (!mounted) return;

                                    final success = tableReq
                                            .lastSuccessResponse?['success'] ==
                                        true;

                                    if (success) {
                                      final orderId =
                                          'order_${DateTime.now().millisecondsSinceEpoch}';
                                    

                                      debugPrint('Order saved: $orderId');
                                      final saved =
                                          HiveOrderService.getOrder(orderId);
                                      if (saved != null) {
                                        debugPrint(' ORDER VERIFIED IN HIVE');
                                        debugPrint(
                                            'Order ID       : ${saved.orderId}');
                                        debugPrint(
                                            'Created At     : ${saved.createdAt}');
                                        debugPrint(
                                            'Is Business    : ${saved.isBusinessOrder}');
                                        debugPrint(
                                            'Subtotal       : \$${saved.subtotal.toStringAsFixed(2)}');
                                        debugPrint(
                                            'Total Items    : ${saved.items.length}');
                                        for (final item in saved.items) {
                                          debugPrint(
                                              '  > ${item.product.name} x${item.quantity} — \$${item.lineTotal.toStringAsFixed(2)}');
                                          if (item.note != null &&
                                              item.note!.isNotEmpty) {
                                            debugPrint(
                                                '    Note: ${item.note}');
                                          }
                                          if (item.selectedVariant != null) {
                                            debugPrint(
                                                '    Variant: ${item.selectedVariant!.optionValues.join(' / ')}');
                                          }
                                          if (item.selectedAddons.isNotEmpty) {
                                            debugPrint(
                                                '    Addons: ${item.selectedAddons.map((a) => a.name).join(', ')}');
                                          }
                                        }
                                        debugPrint(
                                            'Total Orders in box : ${HiveOrderService.getAllOrders().length}');
                                      } else {
                                        debugPrint(
                                            ' ORDER NOT FOUND IN HIVE — something went wrong');
                                      }

                                      if (isBusiness) {
                                        debugPrint('===== CART ITEMS =====');
                                        for (final item in cart.items) {
                                          final p = item.product;
                                          debugPrint('---------------------');
                                          debugPrint('ID            : ${p.id}');
                                          debugPrint(
                                              'Name          : ${p.name}');
                                          debugPrint(
                                              'Description   : ${p.description}');
                                          debugPrint(
                                              'Image         : ${p.image}');
                                          debugPrint(
                                              'Admin ID      : ${p.adminId}');
                                          debugPrint('SKU           : ${p.sku}');
                                          debugPrint(
                                              'Categories    : ${p.categories}');
                                          debugPrint(
                                              'Sold By       : ${p.soldBy}');
                                          debugPrint(
                                              'Price         : \$${p.price.toStringAsFixed(2)}');
                                          debugPrint(
                                              'Cost Price    : \$${p.costPrice.toStringAsFixed(2)}');
                                          debugPrint(
                                              'Display Price : \$${p.displayPrice.toStringAsFixed(2)}');
                                          debugPrint(
                                              'Is Veg        : ${p.isVeg}');
                                          debugPrint(
                                              'Is Available  : ${p.isAvailable}');
                                          debugPrint(
                                              'Uses Offer Px : ${p.usesOfferPrice}');
                                          debugPrint(
                                              'Is Taxable    : ${p.isTaxable}');
                                          debugPrint(
                                              'Uses Stocks   : ${p.usesStocks}');
                                          debugPrint(
                                              'Show Ordering : ${p.showInOrdering}');
                                          debugPrint(
                                              'In Stock      : ${p.inStock}');
                                          debugPrint(
                                              'Low Stock     : ${p.lowStock}');
                                          debugPrint(
                                              'Ordered Count : ${p.orderedCount}');
                                          debugPrint(
                                              'Tags          : ${p.tags.join(', ')}');
                                          debugPrint(
                                              'Has Variants  : ${p.hasVariants}');
                                          if (p.hasVariants) {
                                            final v = p.variants!;
                                            debugPrint(
                                                '  Variant ID       : ${v.id}');
                                            debugPrint(
                                                '  Variant Admin ID : ${v.adminId}');
                                            debugPrint('  Options:');
                                            for (final opt in v.options) {
                                              debugPrint(
                                                  '    [${opt.id}] ${opt.title}: ${opt.values.join(', ')}');
                                            }
                                            debugPrint('  Variant Items:');
                                            for (final vi in v.variantItems) {
                                              debugPrint(
                                                  '    [${vi.id}] ${vi.optionValues.join(' / ')} — \$${vi.price.toStringAsFixed(2)} | Cost: \$${vi.costPrice.toStringAsFixed(2)} | Stock: ${vi.inStock} | Available: ${vi.isAvailable}');
                                            }
                                          }
                                          if (p.addons.isNotEmpty) {
                                            debugPrint('  Addons:');
                                            for (final a in p.addons) {
                                              debugPrint(
                                                  '    [${a.id}] ${a.name} — \$${a.price.toStringAsFixed(2)} | Max: ${a.maxAvailable} | ${a.description}');
                                            }
                                          }
                                          debugPrint(
                                              'Qty in Cart   : ${item.quantity}');
                                          debugPrint(
                                              'Note          : ${item.note ?? '—'}');
                                          debugPrint(
                                              'Line Total    : \$${item.lineTotal.toStringAsFixed(2)}');
                                        }
                                        debugPrint('---------------------');
                                        debugPrint(
                                            'Subtotal   : \$${cart.subtotal.toStringAsFixed(2)}');
                                        debugPrint(
                                            'Total      : \$${cart.total.toStringAsFixed(2)}');
                                        debugPrint('=====================');

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              tableReq.lastSuccessResponse?[
                                                      'message'] ??
                                                  'Order placed!',
                                            ),
                                            backgroundColor: AppColors.terracotta,
                                          ),
                                        );
                                      } else {
                                        context.push('/cart/checkout');
                                      }

                                      cart.clear();
                                    } else {
                                      debugPrint(
                                          ' FOOD REQUEST FAILED — ${tableReq.message}');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(tableReq.message ??
                                              'Failed to place order.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _PriceSummaryRow extends StatelessWidget {
  final String label;
  final double value;

  const _PriceSummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.text.bodyMedium?.copyWith(color: AppColors.textLight),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: context.text.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.backgroundDark,
          ),
        ),
      ],
    );
  }
}