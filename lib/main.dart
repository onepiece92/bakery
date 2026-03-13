import 'package:bakery_flutter/models/product/hive/addon_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/order_hivemodel.dart';
import 'package:bakery_flutter/models/product/hive/order_item_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/product_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/variant_snapshot.dart';
import 'package:bakery_flutter/providers/category_provider.dart';
import 'package:bakery_flutter/providers/customerlogin_provider.dart';
import 'package:bakery_flutter/providers/order_provider.dart';
import 'package:bakery_flutter/providers/product_provider.dart';
import 'package:bakery_flutter/providers/profile_provider.dart';
import 'package:bakery_flutter/providers/qrlogin_provider.dart';
import 'package:bakery_flutter/providers/table_request_provider.dart';
import 'package:bakery_flutter/providers/view_provider.dart';
import 'package:bakery_flutter/services/hive_services/order_hive_services.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/nav_provider.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.instance.init();
  await Hive.initFlutter();

  Hive.registerAdapter(HiveAddonSnapshotAdapter());
  Hive.registerAdapter(HiveVariantSnapshotAdapter());
  Hive.registerAdapter(HiveProductSnapshotAdapter());
  Hive.registerAdapter(HiveOrderItemSnapshotAdapter());
  Hive.registerAdapter(OrderModelAdapter());

  await HiveOrderService.openBox();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const BakeryApp());
}

class BakeryApp extends StatefulWidget {
  const BakeryApp({super.key});

  @override
  State<BakeryApp> createState() => _BakeryAppState();
}

class _BakeryAppState extends State<BakeryApp> {
  // Create provider instance here so we can pass it to the router
  final _loginProvider = CustomerLoginProvider();
  late final _router = createRouter(_loginProvider);

  @override
  void dispose() {
    _loginProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ViewModeProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => TableRequestProvider()),
        ChangeNotifierProvider(create: (_) => QRLoginProvider()),
        // Use .value so the same instance is shared with the router
        ChangeNotifierProvider.value(value: _loginProvider),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp.router(
        title: 'Foxys Corner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}