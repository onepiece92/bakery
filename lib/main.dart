import 'package:bakery_flutter/models/product/hive/addon_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/order_hivemodel.dart';
import 'package:bakery_flutter/models/product/hive/order_item_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/product_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/variant_snapshot.dart';
import 'package:bakery_flutter/providers/category_provider.dart';
import 'package:bakery_flutter/providers/product_provider.dart';
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

class BakeryApp extends StatelessWidget {
  const BakeryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        // ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ViewModeProvider()),
      ],
      child: MaterialApp.router(
        title: 'Foxys Corner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}