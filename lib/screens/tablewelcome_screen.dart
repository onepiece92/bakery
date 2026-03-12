import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TableWelcomeScreen extends StatelessWidget {
  const TableWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final maxWidth = isWide ? 500.0 : double.infinity;

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              "Foxy's Corner",
              style: TextStyle(
                color: Color(0xFFE8A87C),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: Icon(Icons.restaurant, color: Colors.white54, size: 60),
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.30, 0.55, 1.0],
                      colors: [
                        Color(0x77000000),
                        Color(0x11000000),
                        Color(0xBB000000),
                        Color(0xFF000000),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom content
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 28,
                        bottom: MediaQuery.of(context).padding.bottom + 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Session expired banner
                          _SessionExpiredBanner(onDismiss: () {}),
                          const SizedBox(height: 20),

                          // Tag pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE84C1E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ELEGANCE IN DINING',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            "Welcome to Foxy's Corner",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Table badge
                          const _TableNumberBadge(tableNumber: 'Table 4'),
                          const SizedBox(height: 28),

                          // Start Ordering button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE84C1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start Ordering',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          const Text(
                            'Ordering for Table 4',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Dining with friends? Join a group to sync your orders\nand split the bill effortlessly.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Session expired inline banner ──────────────────────────────────────────

class _SessionExpiredBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _SessionExpiredBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE84C1E).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE84C1E).withOpacity(0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_clock_outlined, color: Color(0xFFE84C1E), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Expired',
                  style: TextStyle(
                    color: Color(0xFFE84C1E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your session is no longer valid. Please scan the table QR code again to continue.',
                  style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: Colors.white38, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Scan QR hint ───────────────────────────────────────────────────────────

class _ScanQrHint extends StatelessWidget {
  const _ScanQrHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner_rounded, color: Colors.white38, size: 20),
          SizedBox(width: 10),
          Text(
            'Scan the table QR code to log in',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Splash ─────────────────────────────────────────────────────────────────

class SplashCheckView extends StatelessWidget {
  const SplashCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.network(
                'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF1A1A1A)),
              ),
            ),
          ),
          const Positioned.fill(child: ColoredBox(color: Color(0xBB000000))),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Foxy's Corner",
                  style: TextStyle(
                    color: Color(0xFFE8A87C),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFFE84C1E).withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verifying session…',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Invalid QR ─────────────────────────────────────────────────────────────

class InvalidQrView extends StatelessWidget {
  const InvalidQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 72, color: Colors.white24),
              SizedBox(height: 24),
              Text(
                'Scan Table QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Please scan the QR code on your table to start ordering.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Table badge ────────────────────────────────────────────────────────────

class _TableNumberBadge extends StatelessWidget {
  final String tableNumber;
  const _TableNumberBadge({required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE84C1E).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE84C1E).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.table_restaurant_outlined, color: Color(0xFFE84C1E), size: 14),
          const SizedBox(width: 8),
          const Text('Table: ', style: TextStyle(color: Colors.white54, fontSize: 11)),
          Text(
            tableNumber,
            style: const TextStyle(
              color: Color(0xFFE84C1E),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}