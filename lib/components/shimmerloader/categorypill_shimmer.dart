import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryPillShimmer extends StatelessWidget {
  final double width;

  const CategoryPillShimmer({
    super.key,
    this.width = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}