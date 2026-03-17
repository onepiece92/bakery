// home_screen.dart
import 'package:bakery_flutter/components/confirmation_dialog.dart';
import 'package:bakery_flutter/components/reorder_card.dart';
import 'package:bakery_flutter/extensions/string_casing_extension.dart';
import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:bakery_flutter/models/product/product_model.dart';
import 'package:bakery_flutter/models/services_model.dart';
import 'package:bakery_flutter/providers/order_provider.dart';
import 'package:bakery_flutter/providers/product_provider.dart';
import 'package:bakery_flutter/providers/category_provider.dart';
import 'package:bakery_flutter/providers/table_request_provider.dart';
import 'package:bakery_flutter/providers/view_provider.dart';
import 'package:bakery_flutter/screens/shimmer/homepage_shimmer.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:bakery_flutter/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../components/category_pill.dart';
import '../../components/product_card.dart';
import '../../components/grid_product_card.dart';
import '../../components/section_header.dart';
import '../../providers/nav_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sortBy = 'default';
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // FIX 1: Flag so the intro animation only plays ONCE on first load,
  // never re-triggers when navigating back from QR scanner or other pages.
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoad();
      if (mounted && !_hasAnimated) {
        _hasAnimated = true;
        _animCtrl.forward();
      }
    });
  }

  // FIX 2: didChangeDependencies is called when the route is popped back to
  // this screen. Restore the correct SystemUI here so the QR scanner's
  // edgeToEdge mode doesn't leave the home screen in a broken state.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  // FIX 3: Separated initial load (always fetches) from pull-to-refresh.
  // On first launch, fetch everything. On return from other screens,
  // _initialLoad is NOT called again because it's only in initState.
  Future<void> _initialLoad() async {
    await Future.wait([
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
    ]);
    if (!mounted) return;
    await Provider.of<FavouritesProvider>(context, listen: false)
        .loadFavourites();
    if (!mounted) return;
    Provider.of<OrderProvider>(context, listen: false).loadOrders();
  }

  // FIX 4: Pull-to-refresh always force-fetches fresh data from server,
  // but NEVER triggers the shimmer (isLoading stays false if data exists).
  // This is only called by the RefreshIndicator swipe gesture.
  Future<void> _refresh() async {
    await Future.wait([
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
    ]);
    if (!mounted) return;
    await Provider.of<FavouritesProvider>(context, listen: false)
        .loadFavourites();
    if (!mounted) return;
    Provider.of<OrderProvider>(context, listen: false).loadOrders();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _quickAdd(Product product) {
    context.read<CartProvider>().addProduct(product);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavouritesProvider>();
    final viewMode = context.watch<ViewModeProvider>();
    final businessName = LocalStorageService.instance.getBusinessName();
    final bool showRecent = _searchQuery.isEmpty && _selectedCategory == 'all';
    final recentOrders = context.watch<OrderProvider>().recentOrders;
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    // FIX 5: Only show shimmer on the true initial load (no data yet).
    // When returning from QR scanner, products already exist → no shimmer flash.
    final isInitialLoad =
        (productProvider.isLoading && productProvider.products.isEmpty) ||
        (categoryProvider.isLoading && categoryProvider.categories.isEmpty);

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500;
      final maxWidth = isWide ? 500.0 : double.infinity;

      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide.none,
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Text(
                  businessName ?? "Foxys Corner".toTitleCase(),
                  style: AppTextStyles.disPlayMediumWhite,
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      final scannedValue =
                          await context.push<String>('/scan');
                      if (scannedValue != null) {
                        debugPrint('Scanned: $scannedValue');
                      }
                      // FIX 6: Explicitly re-assert SystemUI after returning
                      // from the QR scanner, in case didChangeDependencies
                      // was not enough (race condition safety net).
                      if (mounted) {
                        SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.manual,
                          overlays: SystemUiOverlay.values,
                        );
                      }
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: context.theme.dividerColor,
                      foregroundColor: context.colors.onSurfaceVariant,
                      minimumSize: const Size(44, 44),
                    ),
                    icon: const Icon(Icons.qr_code_scanner_outlined, size: 22),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => context.push('/profile/notifications'),
                    style: IconButton.styleFrom(
                      backgroundColor: context.theme.dividerColor,
                      foregroundColor: context.colors.onSurfaceVariant,
                      minimumSize: const Size(44, 44),
                    ),
                    icon: const Icon(Icons.notifications_outlined, size: 22),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              resizeToAvoidBottomInset: false,
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.translucent,
                // FIX 7: FadeTransition wraps the body permanently.
                // Because _animCtrl is already completed on return,
                // opacity stays at 1.0 — no re-fade on navigation back.
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: isInitialLoad
                      ? const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: HomeScreenShimmer(isGrid: false),
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 15),

                            // ── Search ─────────────────────────────────────
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _SearchBar(
                                controller: _searchCtrl,
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                onClear: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ── Category Pills ────────────────────────────
                            SizedBox(
                              height: 60,
                              child: categoryProvider.error != null
                                  ? Center(
                                      child: Text(
                                        'Failed to load categories',
                                        style: context.text.bodySmall,
                                      ),
                                    )
                                  : ListView(
                                      scrollDirection: Axis.horizontal,
                                      clipBehavior: Clip.hardEdge,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      children: [
                                        CategoryPill(
                                          label: 'All',
                                          icon: '✦',
                                          active: _selectedCategory == 'all',
                                          onTap: () {
                                            setState(() =>
                                                _selectedCategory = 'all');
                                            _scrollToTop();
                                            context
                                                .read<NavProvider>()
                                                .triggerCategoryChange();
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        ...categoryProvider.categories.map((c) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: CategoryPill(
                                              label: c.name,
                                              icon: '',
                                              active: _selectedCategory == c.id,
                                              onTap: () {
                                                setState(() =>
                                                    _selectedCategory = c.id);
                                                _scrollToTop();
                                                context
                                                    .read<NavProvider>()
                                                    .triggerCategoryChange();
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                            ),

                            // ── Product List ──────────────────────────────
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _refresh,
                                child: ListView(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 0),
                                  children: [
                                    if (productProvider.error != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 48),
                                        child: Center(
                                          child: Text(
                                            'Error: ${productProvider.error}',
                                            style: context.text.bodySmall,
                                          ),
                                        ),
                                      )
                                    else
                                      Builder(builder: (context) {
                                        final items =
                                            productProvider.filteredProducts(
                                          category: _selectedCategory,
                                          searchQuery: _searchQuery,
                                          sortBy: _sortBy,
                                        );

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (showRecent &&
                                                recentOrders.isNotEmpty) ...[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Recent Orders',
                                                    style: context
                                                        .text.headlineSmall,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () => context.push(
                                                        '/home/recent_orders'),
                                                    child: Text(
                                                      'View all',
                                                      style: context
                                                          .text.bodySmall
                                                          ?.copyWith(
                                                        color: context
                                                            .colors.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                height: 140,
                                                child: ListView.separated(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  itemCount:
                                                      recentOrders.length,
                                                  separatorBuilder: (_, __) =>
                                                      const SizedBox(
                                                          width: 12),
                                                  itemBuilder: (_, i) =>
                                                      GestureDetector(
                                                    onTap: () => context.push(
                                                        '/home/recent_orders'),
                                                    child: SizedBox(
                                                      width: 200,
                                                      child: OrderCard(
                                                        order: recentOrders[i],
                                                        onReorder: () async {
                                                          await ConfirmOrderDialog
                                                              .show(
                                                            context,
                                                            order:
                                                                recentOrders[i],
                                                            onConfirm:
                                                                () async {
                                                              final provider =
                                                                  context.read<
                                                                      TableRequestProvider>();
                                                              final businessId =
                                                                  LocalStorageService
                                                                      .instance
                                                                      .getBusinessId();
                                                              final order =
                                                                  recentOrders[
                                                                      i];

                                                              final foodItems =
                                                                  order.items
                                                                      .map(
                                                                          (item) {
                                                                return FoodItemRequest(
                                                                  product: item
                                                                      .productId,
                                                                  quantity:
                                                                      item.qty,
                                                                  variant: item
                                                                      .variant
                                                                      ?.id,
                                                                  addons: item
                                                                      .addons
                                                                      .map((a) =>
                                                                          FoodAddonRequest(
                                                                            addonId:
                                                                                a.id,
                                                                            quantity:
                                                                                1,
                                                                          ))
                                                                      .toList(),
                                                                );
                                                              }).toList();

                                                              await provider
                                                                  .requestFood(
                                                                businessId:
                                                                    businessId ??
                                                                        "",
                                                                foodItems:
                                                                    foodItems,
                                                              );

                                                              if (context
                                                                      .mounted &&
                                                                  provider.message !=
                                                                      null) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          provider
                                                                              .message!)),
                                                                );
                                                                provider
                                                                    .clearMessage();
                                                              }
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                            ],
                                            if (_searchQuery.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 12),
                                                child: Text(
                                                  '${items.length} result${items.length != 1 ? 's' : ''}',
                                                  style:
                                                      context.text.bodySmall,
                                                ),
                                              ),
                                            SectionHeader(
                                              title: 'Featured Products',
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(width: 8),
                                                  SizedBox(
                                                    width: 100,
                                                    child: _ViewToggle(
                                                      isGrid: viewMode.isGrid,
                                                      onToggle: (v) => context
                                                          .read<
                                                              ViewModeProvider>()
                                                          .setGrid(v),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            if (items.isEmpty)
                                              _EmptyState(
                                                onClear: () => setState(() {
                                                  _searchQuery = '';
                                                  _searchCtrl.clear();
                                                  _sortBy = 'default';
                                                  _selectedCategory = 'all';
                                                }),
                                              )
                                            else if (viewMode.isGrid)
                                              GridView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 12,
                                                  mainAxisSpacing: 12,
                                                  childAspectRatio: 0.8,
                                                ),
                                                itemCount: items.length,
                                                itemBuilder: (_, i) {
                                                  final p = items[i];
                                                  return GridProductCard(
                                                    product: p,
                                                    onTap: () => context.push(
                                                        '/product',
                                                        extra: p),
                                                    onQuickAdd: () =>
                                                        _quickAdd(p),
                                                    isFavourite: favProv
                                                        .isFavourite(p.id),
                                                    onToggleFavourite: () =>
                                                        favProv.toggle(p.id),
                                                  );
                                                },
                                              )
                                            else
                                              ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: items.length,
                                                separatorBuilder: (_, __) =>
                                                    const SizedBox(height: 14),
                                                itemBuilder: (_, i) {
                                                  final p = items[i];
                                                  return ProductCard(
                                                    product: p,
                                                    onTap: () => context.push(
                                                        '/product',
                                                        extra: p),
                                                    onQuickAdd: () =>
                                                        _quickAdd(p),
                                                    isFavourite: favProv
                                                        .isFavourite(p.id),
                                                    onToggleFavourite: () =>
                                                        favProv.toggle(p.id),
                                                  );
                                                },
                                              ),
                                          ],
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Private helper widgets ────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: context.text.bodyMedium?.copyWith(
        color: context.colors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Search breads, pastries...',
        prefixIcon: Icon(
          Icons.search_rounded,
          color: context.colors.onSurfaceVariant,
          size: 20,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  color: context.colors.onSurfaceVariant,
                  size: 16,
                ),
              )
            : null,
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onChanged;

  const _SortButton({required this.sortBy, required this.onChanged});

  static const _options = [
    ('default', 'Default'),
    ('price_low', 'Price: Low → High'),
    ('price_high', 'Price: High → Low'),
    ('popular', 'Most Popular'),
  ];

  @override
  Widget build(BuildContext context) {
    final isActive = sortBy != 'default';
    return TextButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Sort by', style: context.text.headlineSmall),
                const SizedBox(height: 12),
                ..._options.map((opt) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        onChanged(opt.$1);
                        Navigator.pop(context);
                      },
                      title: Text(opt.$2, style: context.text.bodyLarge),
                      trailing: sortBy == opt.$1
                          ? Icon(
                              Icons.check_rounded,
                              color: context.colors.secondaryContainer,
                            )
                          : null,
                    )),
              ],
            ),
          ),
        );
      },
      statesController:
          WidgetStatesController({if (isActive) WidgetState.selected}),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: const Icon(Icons.sort_rounded, size: 20),
    );
  }
}

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

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Flexible(
            child: Lottie.asset(
              'assets/animations/empty_search.json',
              width: 200,
              repeat: false,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          Text('No items found', style: context.text.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filters',
            style: context.text.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onClear,
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}