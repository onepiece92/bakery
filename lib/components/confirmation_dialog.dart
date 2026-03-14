import 'package:flutter/material.dart';
import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:bakery_flutter/models/order.dart';

class ConfirmOrderDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onConfirm;

  const ConfirmOrderDialog({
    super.key,
    required this.order,
    required this.onConfirm,
  });

  /// Shows the dialog and returns true if user confirmed, false otherwise.
  static Future<bool> show(BuildContext context, {required Order order, required VoidCallback onConfirm}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmOrderDialog(order: order, onConfirm: onConfirm),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: context.colors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confirm Reorder',
                          style: context.text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        '${order.totalQty} item${order.totalQty != 1 ? 's' : ''}  ·  ${order.date.split('·').first.trim()}',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: context.theme.dividerColor),
            const SizedBox(height: 12),

            // ── Items ─────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + line total
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.name} × ${item.qty}',
                                  style: context.text.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${item.lineTotal.toStringAsFixed(2)}',
                                style: context.text.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          // Variant
                          if (item.variant != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.tune_rounded,
                                    size: 11,
                                    color: context.colors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.variantLabel}  +\$${item.variant!.price.toStringAsFixed(2)}',
                                  style: context.text.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Addons
                          if (item.addons.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            ...item.addons.map(
                              (a) => Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_circle_outline_rounded,
                                        size: 11,
                                        color: context.colors.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${a.name}  +\$${a.price.toStringAsFixed(2)}',
                                      style: context.text.bodySmall?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            Divider(height: 1, color: context.theme.dividerColor),
            const SizedBox(height: 12),

            // ── Grand Total ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: context.text.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: context.text.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Actions ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                    child: const Text('Reorder'),
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