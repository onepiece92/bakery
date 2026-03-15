import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrderCardShimmer extends StatelessWidget {
  const OrderCardShimmer({super.key});

  Widget _box({
    double? width,
    double? height,
    BorderRadius? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius ?? BorderRadius.circular(4),
      ),
    );
  }

  Widget _orderItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _box(height: 13)),
              const SizedBox(width: 12),
              _box(width: 40, height: 13),
            ],
          ),
          const SizedBox(height: 4),
          _box(width: 120, height: 11),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Date
            _box(width: 120, height: 11),

            const SizedBox(height: 10),

            /// Order items
            _orderItem(),
            _orderItem(),
            _orderItem(),

            /// Divider
            const Divider(height: 20),

            /// Total section
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 80, height: 11),
                    const SizedBox(height: 6),
                    _box(width: 60, height: 18),
                  ],
                ),
                const Spacer(),
                _box(width: 70, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}