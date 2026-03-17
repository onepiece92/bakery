import 'package:bakery_flutter/providers/product_provider.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/cart_provider.dart';
import 'package:intl/intl.dart';
import '../../components/primary_button.dart';
import '../../components/product_card.dart';
import '../../components/grid_product_card.dart';
import '../../providers/favourites_provider.dart';
import '../../components/empty_cart_view.dart';
import 'package:go_router/go_router.dart';

// Dummy address data
class _DummyAddress {
  final String type;
  final String icon;
  final String label;
  final String address;

  const _DummyAddress({
    required this.type,
    required this.icon,
    required this.label,
    required this.address,
  });
}

const _dummyAddr = _DummyAddress(
  type: 'Delivery',
  icon: '🏠',
  label: 'Home',
  address: '42 Maple Street, Apt 3B, San Francisco, CA 94103',
);

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 1;
  int _selectedPayment = 2;
  late final bool _isBusinessSession =
      LocalStorageService.instance.getIsBusinessSession();

  int get _totalSteps => _isBusinessSession ? 2 : 1;

  static const _paymentMethods = [
    (icon: '💳', label: '•••• 4289', sub: 'Visa ending in 4289'),
    (icon: '🍎', label: 'Apple Pay', sub: 'Express checkout'),
    (icon: '💵', label: 'Cash', sub: 'Pay on delivery or pickup'),
  ];

  String _stepLabel(_DummyAddress addr) =>
      addr.type == 'Pickup' ? 'Pickup' : 'Delivery';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addr = _dummyAddr;
    final step1Label = _stepLabel(addr);

    return PopScope(
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 1) setState(() => _step--);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyActions: true,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 28),
              onPressed: () {
                if (_step > 1) {
                  setState(() => _step--);
                } else {
                  context.pop();
                }
              },
            ),
          ),
          title: const Text('Checkout'),
        ),
        body: cart.items.isEmpty
            ? const EmptyCartView()
            : Stack(
                children: [
                  Column(
                    children: [
                      if (!_isBusinessSession)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                          child: Row(
                            children: [
                              _StepIndicator(
                                  label: step1Label, step: 1, current: _step),
                              const SizedBox(width: 6),
                              _StepIndicator(
                                  label: 'Payment & Confirm',
                                  step: 2,
                                  current: _step),
                            ],
                          ),
                        ),

                      // Step content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: (_isBusinessSession && _step == 1)
                                ? _Step1(addr: addr, key: const ValueKey(1))
                                : _Step2(
                                    cart: cart,
                                    addr: addr,
                                    methods: _paymentMethods,
                                    selected: _selectedPayment,
                                    onSelect: (i) =>
                                        setState(() => _selectedPayment = i),
                                    key: const ValueKey(2),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // CTA Button
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: PrimaryButton(
                      label: (_isBusinessSession && _step < 2)
                          ? 'Continue'
                          : 'Place Order — \$${cart.total.toStringAsFixed(2)}',
                      onTap: () {
                        if (_isBusinessSession && _step < 2) {
                          setState(() => _step++);
                        } else {
                          context.go('/cart/checkout/success');
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

class _StepIndicator extends StatelessWidget {
  final String label;
  final int step;
  final int current;

  const _StepIndicator(
      {required this.label, required this.step, required this.current});

  @override
  Widget build(BuildContext context) {
    final active = step <= current;
    final isCurrent = step == current;
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 3,
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  final _DummyAddress addr;

  const _Step1({required this.addr, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${addr.type == 'Pickup' ? 'Pickup' : 'Delivery'} Details',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _InfoTile(
          label: addr.type == 'Pickup' ? 'PICKUP LOCATION' : 'DELIVERY ADDRESS',
          icon: addr.icon,
          title: addr.label,
          subtitle: addr.address,
        ),
        const SizedBox(height: 12),
        _InfoTile(
          label: '${addr.type == 'Pickup' ? 'PICKUP' : 'DELIVERY'} TIME',
          icon: '🕐',
          title:
              'Today, ${DateFormat('h:mm a').format(DateTime.now().add(const Duration(minutes: 25)))}',
          subtitle: null,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SPECIAL INSTRUCTIONS',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontSize: 11, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Any special requests for your order...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                    border: InputBorder.none,
                    isDense: false,
                    contentPadding: const EdgeInsets.only(top: 8),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String icon;
  final String title;
  final String? subtitle;

  const _InfoTile({
    required this.label,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 11, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  final CartProvider cart;
  final _DummyAddress addr;
  final List<({String icon, String label, String sub})> methods;
  final int selected;
  final ValueChanged<int> onSelect;

  const _Step2(
      {required this.cart,
      required this.addr,
      required this.methods,
      required this.selected,
      required this.onSelect,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...cart.items.map((item) {
          final favProv = context.watch<FavouritesProvider>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCard(
              product: item.product,
              onTap: () => context.push('/home/product', extra: item.product),
              onQuickAdd: () => cart.addProduct(item.product),
            ),
          );
        }),
        const SizedBox(height: 24),

        // Total summary card
        Card(
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text('\$${cart.subtotal.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text('Baking fee',
                //         style: Theme.of(context).textTheme.bodyMedium),
                //     Text('\$${CartProvider.bakingFee.toStringAsFixed(2)}',
                //         style: Theme.of(context)
                //             .textTheme
                //             .bodyMedium
                //             ?.copyWith(fontWeight: FontWeight.w500)),
                //   ],
                // ),
                Divider(height: 24, color: Theme.of(context).dividerColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '\$${cart.total.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('Payment Method',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...methods.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: 1.5),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1)
                            : Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(m.icon, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                          Text(m.sub,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Icon(Icons.check_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 12),
                      )
                    else
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2)),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
