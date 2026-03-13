import 'package:bakery_flutter/components/bakery_back_button.dart';
import 'package:bakery_flutter/components/reorder_card.dart';
import 'package:bakery_flutter/models/order.dart';
import 'package:bakery_flutter/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RecentOrdersScreen extends StatefulWidget {
  const RecentOrdersScreen({super.key});

  @override
  State<RecentOrdersScreen> createState() => _RecentOrdersScreenState();
}

class _RecentOrdersScreenState extends State<RecentOrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageCtrl;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;

  List<AnimationController> _cardCtrls = [];
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();

    // ── Page entrance animation ──────────────────────────────────
    _pageCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut));

    // ── Load orders then build card controllers ──────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProv = Provider.of<OrderProvider>(context, listen: false);
      orderProv.loadOrders();

      _orders = orderProv.orders;
      _buildCardControllers(_orders.length);

      // Stagger card animations
      Future.microtask(() async {
        _pageCtrl.forward();
        for (var i = 0; i < _cardCtrls.length; i++) {
          await Future.delayed(Duration(milliseconds: 150 + i * 100));
          if (mounted) _cardCtrls[i].forward();
        }
      });
    });
  }

  void _buildCardControllers(int count) {
    // Dispose old controllers if any
    for (final c in _cardCtrls) {
      c.dispose();
    }
    _cardCtrls = List.generate(
      count,
      (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 400)),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final totalSpent = orders.fold<double>(0, (sum, o) => sum + o.total);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: BakeryBackButton(),
        ),
        title: const Text('Recent Orders'),
      ),
      body: SafeArea(
        child: orders.isEmpty
            // ── Empty state ──────────────────────────────────────
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text('No orders yet',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text('Your order history will appear here',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              )
            // ── Orders list ──────────────────────────────────────
            : FadeTransition(
                opacity: _pageFade,
                child: SlideTransition(
                  position: _pageSlide,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    children: [
                      // ── Summary card ─────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order History',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary,
                                    letterSpacing: 1.5,
                                    fontSize: 11,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${orders.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 32,
                                          ),
                                    ),
                                    Text(
                                      'orders placed',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.5),
                                            fontSize: 13,
                                          ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${totalSpent.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 24,
                                          ),
                                    ),
                                    Text(
                                      'total spent',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.5),
                                            fontSize: 13,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Order cards ──────────────────────────────
                      ...orders.asMap().entries.map((entry) {
                        final i = entry.key;
                        final order = entry.value;

                        // Guard against controller list mismatch
                        if (i >= _cardCtrls.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OrderCard(
                              order: order,
                              featured: false,
                              onReorder: () =>
                                  debugPrint('🔁 Reorder Clicked: ${order.id}'),
                            ),
                          );
                        }

                        final ctrl = _cardCtrls[i];
                        return FadeTransition(
                          opacity: CurvedAnimation(
                              parent: ctrl, curve: Curves.easeOut),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: ctrl, curve: Curves.easeOut)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OrderCard(
                                order: order,
                                featured: false,
                                onReorder: () => debugPrint(
                                    '🔁 Reorder Clicked: ${order.id}'),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}