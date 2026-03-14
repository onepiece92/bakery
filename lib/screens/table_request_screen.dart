import 'package:bakery_flutter/components/reorder_card.dart';
import 'package:bakery_flutter/extensions/string_casing_extension.dart';
import 'package:bakery_flutter/models/order.dart';
import 'package:bakery_flutter/models/services_model.dart';
import 'package:bakery_flutter/providers/order_provider.dart';
import 'package:bakery_flutter/providers/table_request_provider.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:bakery_flutter/theme/app_colors.dart';
import 'package:bakery_flutter/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFFE8E8E8),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class TableRequestScreen extends StatelessWidget {
  const TableRequestScreen({super.key});

  Future<void> _handleReorder(
    BuildContext context,
    String businessId,
    Order order,
  ) async {
    final foodItems = order.items
        .map(
          (item) => FoodItemRequest(
            product: item.productId,
            quantity: item.qty,
            note: "",
            // note: item.note,
          ),
        )
        .toList();

    await _handleRequestFood(context, businessId, foodItems);
  }

  Future<void> _handleRequestWaiter(
    BuildContext context,
    String businessId,
    String tableNumber,
  ) async {
    final provider = context.read<TableRequestProvider>();
    await provider.requestWaiter(
      businessId: businessId,
      tableNumber: tableNumber,
    );
    final message = provider.message;
    if (message != null && context.mounted) {
      _showSnack(context, message);
      provider.clearMessage();
    }
  }

  Future<void> _handleRequestWater(
    BuildContext context,
    String businessId,
    String tableNumber,
  ) async {
    final provider = context.read<TableRequestProvider>();
    await provider.requestWater(
      businessId: businessId,
      tableNumber: tableNumber,
      waterProductId: '699bf6167a68b44fbe76e910',
    );
    final message = provider.message;
    if (message != null && context.mounted) {
      _showSnack(context, message);
      provider.clearMessage();
    }
  }

  Future<void> _handleRequestBill(
    BuildContext context,
    String businessId,
    String tableNumber,
  ) async {
    final provider = context.read<TableRequestProvider>();
    await provider.requestBill(
      businessId: businessId,
      tableNumber: tableNumber,
    );
    final message = provider.message;
    if (message != null && context.mounted) {
      _showSnack(context, message);
      provider.clearMessage();
    }
  }

  // ── Food Request Handler ───────────────────────────────────────────────
  Future<void> _handleRequestFood(
    BuildContext context,
    String businessId,
    List<FoodItemRequest> foodItems,
  ) async {
    final provider = context.read<TableRequestProvider>();
    await provider.requestFood(
      businessId: businessId,
      foodItems: foodItems,
    );
    final message = provider.message;
    if (message != null && context.mounted) {
      _showSnack(context, message);
      provider.clearMessage();
    }

    // Show order confirmation if successful
    final successResponse = provider.lastSuccessResponse;
    if (successResponse != null && context.mounted) {
      _showOrderConfirmation(context, successResponse);
    }
  }

  void _showOrderConfirmation(
    BuildContext context,
    Map<String, dynamic> response,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2E7D32),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              response['isReorder'] == true
                  ? 'Reorder Placed!'
                  : 'Order Placed!',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 4),
            if (response['ticketName'] != null)
              Text(
                'Ticket: ${response['ticketName']}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            if (response['grandTotal'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Total: ${response['grandTotal']}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFoodOrderSheet(
    BuildContext context,
    String businessId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FoodOrderSheet(
        onSubmit: (foodItems) {
          Navigator.pop(context);
          _handleRequestFood(context, businessId, foodItems);
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    final isError = message.toLowerCase().contains('error') ||
        message.toLowerCase().contains('failed');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TableRequestProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final businessId = LocalStorageService.instance.getBusinessId() ?? "";
    final tableNumber = LocalStorageService.instance.getCustomerName() ?? "";

    final isLoadingWaiter = provider.isLoadingWaiter;
    final isLoadingBill = provider.isLoadingBill;
    final isLoadingWater = provider.isLoadingWater;
    final isLoadingFood = provider.isLoadingFood;
    final isCoolingDown = provider.isCoolingDown;
    final cooldownSeconds = provider.cooldownSeconds;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final maxWidth = isWide ? 500.0 : double.infinity;

        return ColoredBox(
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Scaffold(
                  appBar: AppBar(
                    scrolledUnderElevation: 0,
                    elevation: 0,
                    title: const Text('Services'),
                    actions: [
                      if (isCoolingDown)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${cooldownSeconds}s',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header row ──────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quick Services',
                              style: AppTextStyles.headlineMedium,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isCoolingDown
                                  ? Container(
                                      key: const ValueKey('cooldown'),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.grey.shade500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Wait ${cooldownSeconds}s',
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      key: const ValueKey('fasttrack'),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Fast Track',
                                        style: AppTextStyles.caption.copyWith(
                                          color: const Color(0xFFE65100),
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ── Table info chip ──────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.table_restaurant_rounded,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                tableNumber.toTitleCase(),
                                style: AppTextStyles.label.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Waiter + Water ───────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: (isLoadingWaiter || isCoolingDown)
                                    ? null
                                    : () => _handleRequestWaiter(
                                          context,
                                          businessId,
                                          tableNumber,
                                        ),
                                child: _ServiceCard(
                                  title: 'Call Waiter',
                                  icon: isLoadingWaiter
                                      ? Icons.hourglass_top_rounded
                                      : Icons.front_hand,
                                  iconColor: const Color(0xFFE65100),
                                  bgColor: const Color(0xFFFFF3E0),
                                  isLoading: isLoadingWaiter,
                                  isCoolingDown: isCoolingDown,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: (isLoadingWater || isCoolingDown)
                                    ? null
                                    : () => _handleRequestWater(
                                          context,
                                          businessId,
                                          tableNumber,
                                        ),
                                child: _ServiceCard(
                                  title: 'Request Water',
                                  icon: isLoadingWater
                                      ? Icons.hourglass_top_rounded
                                      : Icons.water_drop,
                                  iconColor: Colors.blue.shade700,
                                  bgColor: Colors.blue.shade50,
                                  isLoading: isLoadingWater,
                                  isCoolingDown: isCoolingDown,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                 

     
                        GestureDetector(
                          onTap: (isLoadingBill || isCoolingDown)
                              ? null
                              : () => _handleRequestBill(
                                    context,
                                    businessId,
                                    tableNumber,
                                  ),
                          child: _ServiceCard(
                            title: 'Request Final Bill',
                            subtitle: isLoadingBill
                                ? 'Sending request to staff…'
                                : isCoolingDown
                                    ? 'Next request available in ${cooldownSeconds}s'
                                    : 'Ready to conclude your experience?',
                            icon: isLoadingBill
                                ? Icons.hourglass_top_rounded
                                : Icons.receipt_long,
                            iconColor: const Color(0xFFE65100),
                            bgColor: const Color(0xFFFFF3E0),
                            isWide: true,
                            isLoading: isLoadingBill,
                            isCoolingDown: isCoolingDown,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // ── Recent Orders ────────────────────────────────────────────
                        Consumer<OrderProvider>(
                          builder: (context, orderProvider, _) {
                            final recentOrders = orderProvider.recentOrders;
                            if (recentOrders.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Recent Orders',
                                        style: AppTextStyles.headlineMedium),
                                    GestureDetector(
                                      onTap: () =>
                                          context.push('/home/recent_orders'),
                                      child: Text(
                                        'View all →',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 140,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: recentOrders.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (_, i) => SizedBox(
                                      width: 200,
                                      child: OrderCard(
                                        order: recentOrders[i],
                                        featured: i == 0,
                                        onReorder: () => _handleReorder(
                                          context,
                                          businessId,
                                          recentOrders[i],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Food Order Sheet ───────────────────────────────────────────────────────────

class _FoodOrderSheet extends StatefulWidget {
  final void Function(List<FoodItemRequest> items) onSubmit;

  const _FoodOrderSheet({required this.onSubmit});

  @override
  State<_FoodOrderSheet> createState() => _FoodOrderSheetState();
}

class _FoodOrderSheetState extends State<_FoodOrderSheet> {
  // Each entry: { productId, name, quantity }
  final List<Map<String, dynamic>> _items = [
    {'productId': '', 'name': '', 'quantity': 1},
  ];

  void _addItem() {
    setState(() {
      _items.add({'productId': '', 'name': '', 'quantity': 1});
    });
  }

  void _removeItem(int index) {
    if (_items.length == 1) return;
    setState(() => _items.removeAt(index));
  }

  void _submit() {
    final foodItems = _items
        .where((e) => (e['productId'] as String).isNotEmpty)
        .map(
          (e) => FoodItemRequest(
            product: e['productId'] as String,
            quantity: e['quantity'] as int,
          ),
        )
        .toList();

    if (foodItems.isEmpty) return;
    widget.onSubmit(foodItems);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Order Food', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Enter product IDs and quantities',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),

          // Items list
          ..._items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  // Product ID field
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Product ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (v) => item['productId'] = v.trim(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Quantity stepper
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () {
                            if (item['quantity'] > 1) {
                              setState(() => item['quantity']--);
                            }
                          },
                        ),
                        Text(
                          '${item['quantity']}',
                          style: AppTextStyles.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setState(() => item['quantity']++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Remove button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: _items.length == 1
                          ? Colors.grey.shade300
                          : Colors.red.shade300,
                    ),
                    onPressed: () => _removeItem(i),
                  ),
                ],
              ),
            );
          }),

          // Add item
          TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add another item'),
          ),
          const SizedBox(height: 8),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service Card ───────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool isWide;
  final bool isLoading;
  final bool isCoolingDown;

  const _ServiceCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.isWide = false,
    this.isLoading = false,
    this.isCoolingDown = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isCoolingDown ? Colors.grey.shade400 : iconColor;
    final effectiveBgColor = isCoolingDown ? Colors.grey.shade100 : bgColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: isWide
          ? Row(
              children: [
                _buildIcon(effectiveBgColor, effectiveIconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: isCoolingDown
                              ? Colors.grey.shade400
                              : AppColors.backgroundDark,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isCoolingDown
                                ? Colors.grey.shade400
                                : Colors.blueGrey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFE65100),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: isCoolingDown
                        ? Colors.grey.shade300
                        : Colors.blueGrey.shade200,
                    size: 28,
                  ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(effectiveBgColor, effectiveIconColor),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isCoolingDown
                        ? Colors.grey.shade400
                        : AppColors.backgroundDark,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildIcon(Color bg, Color fg) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(14.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
              ),
            )
          : Icon(icon, color: fg, size: 28),
    );
  }
}
