import 'package:bakery_flutter/models/product/product_model.dart';
import 'package:bakery_flutter/providers/customerlogin_provider.dart';
import 'package:bakery_flutter/providers/qrlogin_provider.dart';
import 'package:bakery_flutter/screens/login_screen.dart';
import 'package:bakery_flutter/screens/qrscan_screen.dart';
import 'package:bakery_flutter/screens/signupprompt_screen.dart';
import 'package:bakery_flutter/screens/table_request_screen.dart';
import 'package:bakery_flutter/screens/tablewelcome_screen.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'app_shell.dart';
import 'package:bakery_flutter/theme/app_text_styles.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_success_screen.dart';
import '../screens/recent_orders_screen.dart';
import '../screens/favourites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/profile_sub_screens.dart';

GoRouter createRouter(
  CustomerLoginProvider loginProvider,
  QRLoginProvider qrLoginProvider,
) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final favouritesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'favourites');
  final cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cart');
  final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: Listenable.merge([loginProvider, qrLoginProvider]),
    redirect: (context, state) {
      final sessionType = LocalStorageService.instance.getSessionType();
      final isLoggedIn = loginProvider.isLoggedIn;
      final hasQrSession = qrLoginProvider.data != null;
      if (sessionType == 'qr' || hasQrSession) return null;
      if (isLoggedIn) return null;
      return null;
    },
    errorBuilder: (context, state) =>
        LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500;
      final maxWidth = isWide ? 500.0 : double.infinity;
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Scaffold(
              appBar: AppBar(title:  Text('Page Not Found', style: AppTextStyles.disPlayMediumWhite ,)),
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
                    Text('Something went wrong',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text("We couldn't find the page you're looking for.",
                        style: Theme.of(context).textTheme.bodyMedium),
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
          ),
        ),
      );
    }),
    routes: [
      // ── Splash / Table Welcome ──────────────────────────────────────
      GoRoute(
        path: '/',
        parentNavigatorKey: rootNavigatorKey,
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

      GoRoute(
        path: '/product',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailScreen(product: product);
        },
      ),

      // ── QR Scanner ─────────────────────────────────────────────────
      GoRoute(
        path: '/scan',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const QrScannerPage(),
      ),

      // ── Checkout flow ───────────────────────────────────────────────
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
        routes: [
          GoRoute(
            path: 'success',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const OrderSuccessScreen(),
          ),
        ],
      ),

        GoRoute(
    path: '/cart-screen',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const CartScreen(),
    routes: [
      GoRoute(
        path: 'checkout',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
        routes: [
          GoRoute(
            path: 'success',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const OrderSuccessScreen(),
          ),
        ],
      ),
    ],
  ),

      // ── Shell (bottom nav) ──────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // ── Branch 0: Home ────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'recent_orders',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const RecentOrdersScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 1: Favourites ──────────────────────────────────
          StatefulShellBranch(
            navigatorKey: favouritesNavigatorKey,
            routes: [
              GoRoute(
                path: '/favourites',
                builder: (context, state) => const FavouritesScreen(),
              ),
            ],
          ),

          // ── Branch 2: Cart ────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: cartNavigatorKey,
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),

          // ── Branch 3: Profile ─────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return ListenableBuilder(
                    listenable:
                        Listenable.merge([loginProvider, qrLoginProvider]),
                    builder: (context, _) {
                      final sessionType =
                          LocalStorageService.instance.getSessionType();
                      final isLoggedIn = loginProvider.isLoggedIn;
                      final hasQrSession = qrLoginProvider.data != null;

                      debugPrint('🔍 PROFILE BUILDER FIRED');
                      debugPrint('   sessionType  : $sessionType');
                      debugPrint('   isLoggedIn   : $isLoggedIn');
                      debugPrint('   hasQrSession : $hasQrSession');

                      if (sessionType == 'qr' || hasQrSession) {
                        return const TableRequestScreen();
                      }
                      if (!isLoggedIn) return const SignupPromptScreen();
                      return const ProfileScreen();
                    },
                  );
                },
                routes: [
                  GoRoute(
                    path: 'login',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const Login(),
                  ),
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
                    parentNavigatorKey: rootNavigatorKey,
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
}