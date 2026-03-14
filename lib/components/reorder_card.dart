import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onReorder;
  final bool featured;

  const OrderCard({
    super.key,
    required this.order,
    this.onReorder,
    this.featured = false,
  });

  Color _textColor(BuildContext context) =>  Theme.of(context).colorScheme.onSurface;


  Color _subTextColor(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        // border: featured
        //     ? null
        //     : Border.all(color: Theme.of(context).dividerColor),
        border:  Border.all(color: Theme.of(context).dividerColor),
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
        //     blurRadius: 14,
        //     offset: const Offset(0, 3),
        //   )
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Order ID + Date ──────────────────────────────────
          Row(
            children: [
          
              // const SizedBox(width: 6),
              Text(
                order.date.split('·').first.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _subTextColor(context),
                      fontSize: 11,
                    ),
              ),
            ],
          ),

          // ── Status badge ─────────────────────────────────────
          const SizedBox(height: 6),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          //   decoration: BoxDecoration(
          //     color:Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   //   color: featured
          //   //       ? Theme.of(context)
          //   //           .colorScheme
          //   //           .onPrimary
          //   //           .withValues(alpha: 0.15)
          //   //       : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          //   //   borderRadius: BorderRadius.circular(20),
          //   // ),
          //   child: Text(
          //     order.status,
          //     style: Theme.of(context).textTheme.labelSmall?.copyWith(
          //           color:Theme.of(context).colorScheme.primary,
          //           fontSize: 10,
          //           fontWeight: FontWeight.w600,
          //         ),
          //   ),
          //   // child: Text(
          //   //   order.status,
          //   //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
          //   //         color: featured
          //   //             ? Theme.of(context).colorScheme.onPrimary
          //   //             : Theme.of(context).colorScheme.primary,
          //   //         fontSize: 10,
          //   //         fontWeight: FontWeight.w600,
          //   //       ),
          //   // ),
          // ),

          // const SizedBox(height: 10),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name + qty
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} × ${item.qty}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _textColor(context),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        Text(
                          '\$${item.lineTotal.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _textColor(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),

                    // Variant
                    if (item.variant != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 11,
                            color: _subTextColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.variantLabel}  +\$${item.variant!.price.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: _subTextColor(context),
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ],

                    // Addons
                    if (item.addons.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      ...item.addons.map(
                        (a) => Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 11,
                              color: _subTextColor(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${a.name}  +\$${a.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: _subTextColor(context),
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )),

          // ── Divider ───────────────────────────────────────────
          Divider(
            height: 1,
            color: featured
                ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.15)
                : Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 10),

          // ── Total + Reorder ───────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.totalQty} item${order.totalQty != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _subTextColor(context),
                          fontSize: 11,
                        ),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: featured
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              if (onReorder != null) ...[
                const Spacer(),
                TextButton(
                  onPressed: onReorder,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Reorder',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: featured
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: featured
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.5)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.5),
                        ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}