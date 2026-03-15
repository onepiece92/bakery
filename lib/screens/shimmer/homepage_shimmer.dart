import 'package:bakery_flutter/components/shimmerloader/categorypill_shimmer.dart';
import 'package:bakery_flutter/components/shimmerloader/gridproduct_shimmer.dart';
import 'package:bakery_flutter/components/shimmerloader/ordecard_shimmer.dart';
import 'package:bakery_flutter/components/shimmerloader/productcard_shimmer.dart';
import 'package:flutter/material.dart';

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key, this.isGrid = true});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ── Search bar shimmer ─────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// ── Category pills shimmer ─────────────────────
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            children: const [
              CategoryPillShimmer(width: 70),
              SizedBox(width: 10),
              CategoryPillShimmer(width: 90),
              SizedBox(width: 10),
              CategoryPillShimmer(width: 80),
              SizedBox(width: 10),
              CategoryPillShimmer(width: 110),
              SizedBox(width: 10),
              CategoryPillShimmer(width: 85),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            children: [
              /// ── Recent Orders shimmer ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 140, height: 20, color: Colors.grey.shade300),
                  Container(width: 80, height: 16, color: Colors.grey.shade300),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const SizedBox(
                    width: 200,
                    child: OrderCardShimmer(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// ── Featured products header shimmer ───────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 160, height: 22, color: Colors.grey.shade300),
                  Container(width: 100, height: 30, color: Colors.grey.shade300),
                ],
              ),

              const SizedBox(height: 14),

              /// ── Product list/grid shimmer ──────────────
              if (isGrid)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (_, __) => const GridProductShimmer(),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, __) => const ProductCardShimmer(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}