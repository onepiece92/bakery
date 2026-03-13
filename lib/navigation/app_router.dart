import 'package:bakery_flutter/models/product/product_model.dart';
import 'package:bakery_flutter/screens/table_request_screen.dart';
import 'package:bakery_flutter/screens/tablewelcome_screen.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'app_shell.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_success_screen.dart';
import '../screens/recent_orders_screen.dart';
import '../screens/favourites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/profile_sub_screens.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _favouritesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'favourites');
final GlobalKey<NavigatorState> _cartNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'cart');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final sessionType = LocalStorageService.instance.getSessionType();
    final currentLocation = state.matchedLocation;
    debugPrint('====================================');
    debugPrint('REDIRECT CHECK');
    debugPrint('currentLocation : $currentLocation');
    debugPrint('sessionType     : $sessionType');
    debugPrint('====================================');
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Lottie.asset(
              'assets/animations/error_404.json',
              width: 250,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "We couldn't find the page you're looking for.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              while (context.canPop()) {
                context.pop();
              }
              context.go('/home');
            },
            child: const Text('Return to Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final uri = Uri.base;
        final tableNumber = uri.queryParameters['tableNumber'];
        final businessId = uri.queryParameters['businessId'];
        debugPrint('====================================');
        debugPrint('ROUTE: /');
        debugPrint('tableId(url)   : $tableNumber');
        debugPrint('businessId(url): $businessId');
        debugPrint('====================================');

        return TableWelcomeScreen(
          tableId: tableNumber,
          businessId: businessId,
        );
      },
    ),

    // ── /login → UserLoginScreen ───────────────────────────────────────────

    // ── Main app shell (home, favourites, cart, profile) ───────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // ── Branch 0: Home ─────────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'product',
                  builder: (context, state) {
                    final product = state.extra as Product;
                    return ProductDetailScreen(product: product);
                  },
                ),
                GoRoute(
                  path: 'recent_orders',
                  builder: (context, state) => const RecentOrdersScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Branch 1: Favourites ────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _favouritesNavigatorKey,
          routes: [
            GoRoute(
              path: '/favourites',
              builder: (context, state) => const FavouritesScreen(),
              routes: [
                GoRoute(
                  path: 'product',
                  builder: (context, state) {
                    final product = state.extra as Product;
                    return ProductDetailScreen(product: product);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Branch 2: Cart & Checkout ───────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _cartNavigatorKey,
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
              routes: [
                GoRoute(
                  path: 'checkout',
                  // Cart and checkout handle guest/session logic internally
                  builder: (context, state) => const CheckoutScreen(),
                  routes: [
                    GoRoute(
                      path: 'success',
                      builder: (context, state) => const OrderSuccessScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ── Branch 3: Profile ───────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) {
                final sessionType =
                    LocalStorageService.instance.getSessionType();

                debugPrint('====================================');
                debugPrint('ROUTE: /profile');
                debugPrint('sessionType : $sessionType');
                debugPrint('====================================');

                // QR → TableRequestScreen
                // manual / guest → ProfileScreen
                // (ProfileScreen handles guest UI internally)
                return sessionType == 'qr'
                    ? const TableRequestScreen()
                    : const ProfileScreen();
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'addresses',
                  builder: (context, state) => const SavedAddressesScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const AddNewAddressScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'payments',
                  builder: (context, state) => const PaymentMethodsScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'orders',
                  builder: (context, state) => const RecentOrdersScreen(),
                ),
                GoRoute(
                  path: 'favourites',
                  builder: (context, state) => const FavouritesScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
