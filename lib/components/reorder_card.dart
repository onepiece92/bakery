// import 'package:flutter/material.dart';
// import '../models/order.dart';

// class OrderCard extends StatelessWidget {
//   final Order order;
//   final VoidCallback? onReorder;
//   final bool featured;

//   const OrderCard({
//     super.key,
//     required this.order,
//     this.onReorder,
//     this.featured = false,
//   });

//   Color _textColor(BuildContext context) =>  Theme.of(context).colorScheme.onSurface;

//   Color _subTextColor(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(18),
//         // border: featured
//         //     ? null
//         //     : Border.all(color: Theme.of(context).dividerColor),
//         border:  Border.all(color: Theme.of(context).dividerColor),
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
//         //     blurRadius: 14,
//         //     offset: const Offset(0, 3),
//         //   )
//         // ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Order ID + Date ──────────────────────────────────
//           Row(
//             children: [

//               // const SizedBox(width: 6),
//               Text(
//                 order.date.split('·').first.trim(),
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: _subTextColor(context),
//                       fontSize: 11,
//                     ),
//               ),
//             ],
//           ),

//           // ── Status badge ─────────────────────────────────────
//           const SizedBox(height: 6),
//           // Container(
//           //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           //   decoration: BoxDecoration(
//           //     color:Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
//           //     borderRadius: BorderRadius.circular(20),
//           //   ),
//           //   //   color: featured
//           //   //       ? Theme.of(context)
//           //   //           .colorScheme
//           //   //           .onPrimary
//           //   //           .withValues(alpha: 0.15)
//           //   //       : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
//           //   //   borderRadius: BorderRadius.circular(20),
//           //   // ),
//           //   child: Text(
//           //     order.status,
//           //     style: Theme.of(context).textTheme.labelSmall?.copyWith(
//           //           color:Theme.of(context).colorScheme.primary,
//           //           fontSize: 10,
//           //           fontWeight: FontWeight.w600,
//           //         ),
//           //   ),
//           //   // child: Text(
//           //   //   order.status,
//           //   //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
//           //   //         color: featured
//           //   //             ? Theme.of(context).colorScheme.onPrimary
//           //   //             : Theme.of(context).colorScheme.primary,
//           //   //         fontSize: 10,
//           //   //         fontWeight: FontWeight.w600,
//           //   //       ),
//           //   // ),
//           // ),

//           // const SizedBox(height: 10),
//           ...order.items.map((item) => Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Product name + qty
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             '${item.name} × ${item.qty}',
//                             style:
//                                 Theme.of(context).textTheme.bodySmall?.copyWith(
//                                       color: _textColor(context),
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                           ),
//                         ),
//                         Text(
//                           '\$${item.lineTotal.toStringAsFixed(2)}',
//                           style:
//                               Theme.of(context).textTheme.bodySmall?.copyWith(
//                                     color: _textColor(context),
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                         ),
//                       ],
//                     ),

//                     // Variant
//                     if (item.variant != null) ...[
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.tune_rounded,
//                             size: 11,
//                             color: _subTextColor(context),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${item.variantLabel}  +\$${item.variant!.price.toStringAsFixed(2)}',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall
//                                 ?.copyWith(
//                                   color: _subTextColor(context),
//                                   fontSize: 11,
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ],

//                     // Addons
//                     if (item.addons.isNotEmpty) ...[
//                       const SizedBox(height: 2),
//                       ...item.addons.map(
//                         (a) => Row(
//                           children: [
//                             Icon(
//                               Icons.add_circle_outline_rounded,
//                               size: 11,
//                               color: _subTextColor(context),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${a.name}  +\$${a.price.toStringAsFixed(2)}',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall
//                                   ?.copyWith(
//                                     color: _subTextColor(context),
//                                     fontSize: 11,
//                                   ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               )),

//           // ── Divider ───────────────────────────────────────────
//           Divider(
//             height: 1,
//             color: featured
//                 ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.15)
//                 : Theme.of(context).dividerColor,
//           ),
//           const SizedBox(height: 10),

//           // ── Total + Reorder ───────────────────────────────────
//           Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${order.totalQty} item${order.totalQty != 1 ? 's' : ''}',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: _subTextColor(context),
//                           fontSize: 11,
//                         ),
//                   ),
//                   Text(
//                     '\$${order.total.toStringAsFixed(2)}',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           color: featured
//                               ? Theme.of(context).colorScheme.onPrimary
//                               : Theme.of(context).colorScheme.primary,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                 ],
//               ),
//               if (onReorder != null) ...[
//                 const Spacer(),
//                 TextButton(
//                   onPressed: onReorder,
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     minimumSize: Size.zero,
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                   ),
//                   child: Text(
//                     'Reorder',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: featured
//                               ? Theme.of(context).colorScheme.onPrimary
//                               : Theme.of(context).colorScheme.primary,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                           decoration: TextDecoration.underline,
//                           decorationColor: featured
//                               ? Theme.of(context)
//                                   .colorScheme
//                                   .onPrimary
//                                   .withValues(alpha: 0.5)
//                               : Theme.of(context)
//                                   .colorScheme
//                                   .primary
//                                   .withValues(alpha: 0.5),
//                         ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
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

  Color _textColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _subTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        return bounded
            ? _BoundedCard(
                order: order,
                onReorder: onReorder,
                textColor: _textColor(context),
                subTextColor: _subTextColor(context),
              )
            : _UnboundedCard(
                order: order,
                onReorder: onReorder,
                textColor: _textColor(context),
                subTextColor: _subTextColor(context),
              );
      },
    );
  }
}

// ── Bounded variant (horizontal list, fixed height) ───────────────────────────

class _BoundedCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onReorder;
  final Color textColor;
  final Color subTextColor;

  const _BoundedCard({
    required this.order,
    required this.onReorder,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + Items scroll together
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.date.split('·').first.trim(),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subTextColor,
                          fontSize: 10,
                        ),
                  ),
                  const SizedBox(height: 6),
                  _ItemList(
                    order: order,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    fontSize: 12,
                    extraFontSize: 10,
                    itemSpacing: 6,
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: Theme.of(context).dividerColor),
          _Footer(
            order: order,
            onReorder: onReorder,
            subTextColor: subTextColor,
            totalFontSize: 17,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          ),
        ],
      ),
    );
  }
}

// ── Unbounded variant (vertical list) ─────────────────────────────────────────

class _UnboundedCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onReorder;
  final Color textColor;
  final Color subTextColor;

  const _UnboundedCard({
    required this.order,
    required this.onReorder,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date + Items scroll together
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.date.split('·').first.trim(),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subTextColor,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _ItemList(
                    order: order,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    fontSize: 13,
                    extraFontSize: 11,
                    itemSpacing: 8,
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: Theme.of(context).dividerColor),
          _Footer(
            order: order,
            onReorder: onReorder,
            subTextColor: subTextColor,
            totalFontSize: 20,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          ),
        ],
      ),
    );
  }
}

// ── Shared: item list ─────────────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final Order order;
  final Color textColor;
  final Color subTextColor;
  final double fontSize;
  final double extraFontSize;
  final double itemSpacing;

  const _ItemList({
    required this.order,
    required this.textColor,
    required this.subTextColor,
    required this.fontSize,
    required this.extraFontSize,
    required this.itemSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: order.items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: itemSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name} × ${item.qty}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: textColor,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Rs ${item.lineTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  if (item.variant != null) ...[
                    const SizedBox(height: 2),
                    _ExtraRow(
                      label:
                          '${item.variantLabel}  + Rs ${item.variant!.price.toStringAsFixed(2)}',
                      subTextColor: subTextColor,
                      fontSize: extraFontSize,
                    ),
                  ],
                  if (item.addons.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    ...item.addons.map(
                      (a) => _ExtraRow(
                        label: '${a.name}  + Rs ${a.price.toStringAsFixed(2)}',
                        subTextColor: subTextColor,
                        fontSize: extraFontSize,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Shared: footer ────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final Order order;
  final VoidCallback? onReorder;
  final Color subTextColor;
  final double totalFontSize;
  final EdgeInsets padding;

  const _Footer({
    required this.order,
    required this.onReorder,
    required this.subTextColor,
    required this.totalFontSize,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ' Rs ${order.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: totalFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),
          ),
          if (onReorder != null)
            FilledButton(
              onPressed: onReorder,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Reorder'),
            ),
        ],
      ),
    );
  }
}

// ── Shared: extra row ─────────────────────────────────────────────────────────

class _ExtraRow extends StatelessWidget {
  final String label;
  final Color subTextColor;
  final double fontSize;

  const _ExtraRow({
    required this.label,
    required this.subTextColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: subTextColor.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subTextColor,
                    fontSize: fontSize,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}