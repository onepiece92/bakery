import 'package:bakery_flutter/theme/app_decorations.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class GridProductShimmer extends StatelessWidget {
  const GridProductShimmer({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _box(),
                  ),

                  /// favourite icon shimmer
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _box(
                      width: 28,
                      height: 28,
                      radius: BorderRadius.circular(
                        AppDecorations.radiusXS,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// product name shimmer
                  _box(height: 14, width: double.infinity),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      /// price shimmer
                      Expanded(
                        child: _box(height: 14, width: 60),
                      ),

                      const SizedBox(width: 8),

                      /// add button shimmer
                      _box(
                        width: 28,
                        height: 28,
                        radius: BorderRadius.circular(
                          AppDecorations.radiusS,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}