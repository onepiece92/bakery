import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../components/bottom_nav_bar.dart';
import '../providers/nav_provider.dart';

/// Root app shell — manages bottom nav and screen stack via GoRouter.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    void onNavTap(int index) {
      HapticFeedback.selectionClick();
      if (index == 0 && index == navigationShell.currentIndex) {
        context.read<NavProvider>().triggerHomeTap();
      }
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
       
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              Expanded(child: navigationShell),
              AppBottomNavBar(
                currentIndex: navigationShell.currentIndex,
                onTap: onNavTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}