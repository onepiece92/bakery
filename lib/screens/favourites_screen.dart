import 'package:bakery_flutter/components/empty_favourite.dart';
import 'package:bakery_flutter/components/section_header.dart';
import 'package:bakery_flutter/providers/view_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favourites_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../components/grid_product_card.dart';
import '../../components/product_card.dart';
import '../../components/browse_menu_button.dart';
import 'package:go_router/go_router.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavouritesProvider>();
    final cart = context.read<CartProvider>();
    final products = context.watch<ProductProvider>().products;
    final viewMode = context.watch<ViewModeProvider>();
    final favs = products.where((p) => favProv.isFavourite(p.id)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final maxWidth = isWide ? 500.0 : double.infinity;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide.none,
                ),
              ),
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(
                    'My Favourites',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // ── Section header (mirrors HomeScreen "Featured Products") ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SectionHeader(
                        title:
                            'Favourites',
                            // '${favs.length} saved item${favs.length != 1 ? 's' : ''}',
                        trailing: favs.isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 100,
                                    child: _ViewToggle(
                                      isGrid: viewMode.isGrid,
                                      onToggle: (v) => context
                                          .read<ViewModeProvider>()
                                          .setGrid(v),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ── Product grid or list ──────────────────────────────
                    Expanded(
                      child: favs.isEmpty
                          ? const EmptyFavourites()
                          : viewMode.isGrid
                              ? GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 80),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.8,
                                  ),
                                  itemCount: favs.length,
                                  itemBuilder: (_, i) {
                                    final p = favs[i];
                                    return GridProductCard(
                                      product: p,
                                      onTap: () => context.push(
                                          '/product',
                                          extra: p),
                                      onQuickAdd: () => cart.addProduct(p),
                                      isFavourite: favProv.isFavourite(p.id),
                                      onToggleFavourite: () =>
                                          favProv.toggle(p.id),
                                    );
                                  },
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                      24, 0, 24, 80),
                                  itemCount: favs.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (_, i) {
                                    final p = favs[i];
                                    return ProductCard(
                                      product: p,
                                      onTap: () => context.push(
                                          '/product',
                                          extra: p),
                                      onQuickAdd: () => cart.addProduct(p),
                                      isFavourite: favProv.isFavourite(p.id),
                                      onToggleFavourite: () =>
                                          favProv.toggle(p.id),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── View toggle (identical to HomeScreen's _ViewToggle) ───────────────────────

class _ViewToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onToggle;

  const _ViewToggle({required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: false, icon: Icon(Icons.view_list_rounded)),
        ButtonSegment(value: true, icon: Icon(Icons.grid_view_rounded)),
      ],
      selected: {isGrid},
      onSelectionChanged: (set) => onToggle(set.first),
    );
  }
}