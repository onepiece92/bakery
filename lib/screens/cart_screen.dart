import 'package:bakery_flutter/providers/order_provider.dart';
import 'package:bakery_flutter/services/hive_services/order_hive_services.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/product_provider.dart';
import '../../components/address_selector.dart';
import '../../components/primary_button.dart';
import '../../components/product_card.dart';
import '../../components/grid_product_card.dart';
import '../../components/bakery_back_button.dart';
import '../../providers/favourites_provider.dart';
import '../../components/empty_cart_view.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // void _showAddressSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => AddressBottomSheet(
  //       selectedId: context.read<AddressProvider>().selectedId,
  //       onSelect: (id) => context.read<AddressProvider>().select(id),
  //       onAddNew: () => Navigator.pop(context),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    // final addrProv = context.watch<AddressProvider>();
    final favProv = context.watch<FavouritesProvider>();
    final productProv = context.watch<ProductProvider>();
    final isBusiness = LocalStorageService.instance.getIsBusinessSession();

    // Products not already in cart — pulled from ProductProvider
    final cartIds = cart.items.map((i) => i.product.id).toSet();
    final suggestions = productProv.products
        .where((p) => !cartIds.contains(p.id))
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: BakeryBackButton(),
        ),
        title: const Text('Your Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  '${cart.totalCount} item${cart.totalCount != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
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
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
                          children: [
                            ...cart.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: ProductCard(
                                  product: item.product,
                                  onTap: () => context.push('/home/product',
                                      extra: item.product),
                                  onQuickAdd: () =>
                                      cart.addProduct(item.product),
                                  isFavourite:
                                      favProv.isFavourite(item.product.id),
                                  onToggleFavourite: () =>
                                      favProv.toggle(item.product.id),
                                ),
                              );
                            }),

                            // ── Suggestions ──────────────────────────────
                            // if (suggestions.isNotEmpty) ...[
                            //   const SizedBox(height: 8),
                            //   Text('Add something extra?',
                            //       style: AppTextStyles.headlineSmall),
                            //   const SizedBox(height: 12),
                            //   SizedBox(
                            //     height: 230,
                            //     child: ListView.separated(
                            //       scrollDirection: Axis.horizontal,
                            //       physics: const BouncingScrollPhysics(),
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 4),
                            //       itemCount: suggestions.length,
                            //       separatorBuilder: (_, __) =>
                            //           const SizedBox(width: 14),
                            //       itemBuilder: (_, i) {
                            //         final p = suggestions[i];
                            //         return SizedBox(
                            //           width: 160,
                            //           child: GridProductCard(
                            //             product: p,
                            //             onTap: () => context.push(
                            //                 '/home/product', extra: p),
                            //             onQuickAdd: () =>
                            //                 cart.addProduct(p),
                            //             isFavourite:
                            //                 favProv.isFavourite(p.id),
                            //             onToggleFavourite: () =>
                            //                 favProv.toggle(p.id),
                            //           ),
                            //         );
                            //       },
                            //     ),
                            //   ),
                            //   const SizedBox(height: 16),
                            // ],

                            // ── Address ──────────────────────────────────
                            // Text('DELIVER TO',
                            //     style: AppTextStyles.labelSmall),
                            // const SizedBox(height: 8),
                            // AddressSelector(
                            //   selectedId: addrProv.selectedId,
                            //   onTap: () => _showAddressSheet(context),
                            //   variant: AddressSelectorVariant.compact,
                            // ),
                            // const SizedBox(height: 16),

                            // ── Price summary ─────────────────────────────
                            Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow
                                  .withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDecorations.radiusCard),
                                side: BorderSide(
                                  color: AppColors.darkBrown
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
                                    // _PriceSummaryRow(
                                    //     label: 'Baking fee',
                                    //     value: CartProvider.bakingFee),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Divider(
                                          height: 1,
                                          color: AppColors.softBrown
                                              .withValues(alpha: 0.1)),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total',
                                            style:
                                                AppTextStyles.headlineMedium),
                                        Text(
                                            '\$${cart.total.toStringAsFixed(2)}',
                                            style: AppTextStyles.priceLarge
                                                .copyWith(
                                              color: AppColors.terracotta,
                                            )),
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
            if (cart.items.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: PrimaryButton(
                  label: 'Checkout — \$${cart.total.toStringAsFixed(2)}',
                  onTap: () async {
                    if (cart.items.isNotEmpty) {
                      final orderId =
                          'order_${DateTime.now().millisecondsSinceEpoch}';
                      await context.read<OrderProvider>().placeOrder(
                            items: cart.items.toList(),
                            subtotal: cart.subtotal,
                            isBusinessOrder: isBusiness,
                          );
                      debugPrint('Order saved: $orderId');
                      final saved = HiveOrderService.getOrder(orderId);
                      if (saved != null) {
                        debugPrint(' ORDER VERIFIED IN HIVE');
                        debugPrint('Order ID       : ${saved.orderId}');
                        debugPrint('Created At     : ${saved.createdAt}');
                        debugPrint('Is Business    : ${saved.isBusinessOrder}');
                        debugPrint(
                            'Subtotal       : \$${saved.subtotal.toStringAsFixed(2)}');
                        debugPrint('Total Items    : ${saved.items.length}');
                        for (final item in saved.items) {
                          debugPrint(
                              '  > ${item.product.name} x${item.quantity} — \$${item.lineTotal.toStringAsFixed(2)}');
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
                          debugPrint('Name          : ${p.name}');
                          debugPrint('Description   : ${p.description}');
                          debugPrint('Image         : ${p.image}');
                          debugPrint('Admin ID      : ${p.adminId}');
                          debugPrint('SKU           : ${p.sku}');
                          debugPrint('Categories    : ${p.categories}');
                          debugPrint('Sold By       : ${p.soldBy}');
                          debugPrint(
                              'Price         : \$${p.price.toStringAsFixed(2)}');
                          debugPrint(
                              'Cost Price    : \$${p.costPrice.toStringAsFixed(2)}');
                          debugPrint(
                              'Display Price : \$${p.displayPrice.toStringAsFixed(2)}');
                          debugPrint('Is Veg        : ${p.isVeg}');
                          debugPrint('Is Available  : ${p.isAvailable}');
                          debugPrint('Uses Offer Px : ${p.usesOfferPrice}');
                          debugPrint('Is Taxable    : ${p.isTaxable}');
                          debugPrint('Uses Stocks   : ${p.usesStocks}');
                          debugPrint('Show Ordering : ${p.showInOrdering}');
                          debugPrint('In Stock      : ${p.inStock}');
                          debugPrint('Low Stock     : ${p.lowStock}');
                          debugPrint('Ordered Count : ${p.orderedCount}');
                          debugPrint('Tags          : ${p.tags.join(', ')}');
                          debugPrint('Has Variants  : ${p.hasVariants}');
                          if (p.hasVariants) {
                            final v = p.variants!;
                            debugPrint('  Variant ID       : ${v.id}');
                            debugPrint('  Variant Admin ID : ${v.adminId}');
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
                          debugPrint('Qty in Cart   : ${item.quantity}');
                          debugPrint(
                              'Line Total    : \$${item.lineTotal.toStringAsFixed(2)}');
                        }
                        debugPrint('---------------------');
                        debugPrint(
                            'Subtotal   : \$${cart.subtotal.toStringAsFixed(2)}');
                        debugPrint(
                            'Total      : \$${cart.total.toStringAsFixed(2)}');
                        debugPrint('=====================');
                      } else {
                        context.push('/cart/checkout');
                      }
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
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
        Text(label,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        Text('\$${value.toStringAsFixed(2)}',
            style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.darkBrown)),
      ],
    );
  }
}
