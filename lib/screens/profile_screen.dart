import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:bakery_flutter/providers/customerlogin_provider.dart';
import 'package:bakery_flutter/providers/order_provider.dart';
import 'package:bakery_flutter/providers/profile_provider.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/loyalty_card.dart';
import 'package:go_router/go_router.dart';
import '../../components/service_icon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final storage = LocalStorageService.instance;
        final customerName = provider.isLoaded
            ? provider.name
            : (storage.getCustomerName() ?? 'User');
        final customerEmail = provider.isLoaded ? provider.email : '';
        final initial =
            customerName.isNotEmpty ? customerName[0].toUpperCase() : 'U';

        return LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          final maxWidth = isWide ? 500.0 : double.infinity;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border(
                    // top: BorderSide(color: Colors.grey.shade300),
                    left: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide.none,
                  ),
                ),
                child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyActions: true,
                    scrolledUnderElevation: 0,
                    elevation: 0,
                    title: Text(
                        'My Profile',
                        style: context.text.displayMedium,
                      ), 
                  ),
                  body: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    children: [
                     
                      // const SizedBox(height: 20),

                      // ── Profile card ─────────────────────────────────────
                      GestureDetector(
                        onTap: () => context.push('/profile/edit'),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFFAF3), Color(0x66F5E6D3)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: context.colors.tertiary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  gradient: context.appTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: context.text.displayLarge?.copyWith(
                                    color: context.colors.onPrimary,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: context.text.headlineLarge,
                                    ),
                                    if (customerEmail.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        customerEmail,
                                        style: context.text.bodySmall
                                            ?.copyWith(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //       horizontal: 10, vertical: 4),
                                    //   decoration: BoxDecoration(
                                    //     color: context.colors.tertiary
                                    //         .withValues(alpha: 0.12),
                                    //     borderRadius: BorderRadius.circular(8),
                                    //   ),
                                    //   child: Text(
                                    //     '🥐 Croissant Member',
                                    //     style:
                                    //         context.text.labelMedium?.copyWith(
                                    //       color: context.colors.tertiary,
                                    //       fontSize: 11,
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: context.colors.onSurfaceVariant,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // const LoyaltyCard(),
                      // const SizedBox(height: 24),

                      // ── Orders & History ─────────────────────────────────
                      const _SectionHeader(label: 'ORDERS & HISTORY'),
                      const SizedBox(height: 8),
                      Consumer<OrderProvider>(
                        builder: (context, orderProvider, _) => _MenuTile(
                          icon: '📦',
                          label: 'My Orders',
                          sub: '${orderProvider.orders.length} recent orders',
                          onTap: () => context.push('/profile/orders'),
                        ),
                      ),
                      _MenuTile(
                        icon: '❤️',
                        label: 'Favourites',
                        sub: 'Saved items',
                        onTap: () => context.push('/profile/favourites'),
                      ),
                      const SizedBox(height: 16),

                      // ── Account ──────────────────────────────────────────
                      const _SectionHeader(label: 'Account'),
                      // const SizedBox(height: 8),
                      // _MenuTile(
                      //   icon: '📍',
                      //   label: 'Saved Addresses',
                      //   sub: 'Manage delivery locations',
                      //   onTap: () => context.push('/profile/addresses'),
                      // ),
                      _MenuTile(
                        icon: '💳',
                        label: 'Payment Methods',
                        sub: 'Cards & digital wallets',
                        onTap: () => context.push('/profile/payments'),
                      ),
                      const SizedBox(height: 16),

                      // ── Preferences ──────────────────────────────────────
                      const _SectionHeader(label: 'Preferences'),
                      const SizedBox(height: 8),
                      _MenuTile(
                        icon: '🔔',
                        label: 'Notifications',
                        sub: 'Push & email settings',
                        onTap: () => context.push('/profile/notifications'),
                      ),
                      _MenuTile(
                        icon: '⚙️',
                        label: 'Settings',
                        sub: 'App preferences',
                        onTap: () => context.push('/profile/settings'),
                      ),
                      const SizedBox(height: 20),

                      // ── Sign Out ─────────────────────────────────────────
                      GestureDetector(
                        onTap: () async {
                          await context.read<CustomerLoginProvider>().logout();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.errorContainer
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              ServiceIcon(
                                icon: '👋',
                                backgroundColor: context.colors.errorContainer,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Sign Out',
                                style: context.text.bodyLarge?.copyWith(
                                  color: context.colors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.text.labelSmall?.copyWith(
        letterSpacing: 1,
        fontSize: 11,
      ),
    );
  }
}

// ── Menu Tile ──────────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final String icon;
  final String label;
  final String? sub;
  final VoidCallback? onTap;

  const _MenuTile(
      {required this.icon, required this.label, this.sub, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ServiceIcon(icon: icon, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.text.bodyLarge),
                  if (sub != null)
                    Text(
                      sub!,
                      style: context.text.bodySmall?.copyWith(fontSize: 12),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
