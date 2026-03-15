import 'package:bakery_flutter/theme/app_decorations.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Image shimmer
              _box(width: 90, height: 100),

              const SizedBox(width: 8),

              /// Text column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Name + favourite
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _box(height: 14, width: double.infinity),
                          ),
                          const SizedBox(width: 6),
                          _box(
                            width: 16,
                            height: 16,
                            radius: BorderRadius.circular(
                                AppDecorations.radiusXS),
                          ),
                        ],
                      ),

                      /// Description shimmer
                      _box(height: 12, width: double.infinity),

                      /// Price + Add button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _box(height: 14, width: 60),

                          _box(
                            width: 32,
                            height: 32,
                            radius: BorderRadius.circular(
                                AppDecorations.radiusSM),
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
      ),
    );
  }
}