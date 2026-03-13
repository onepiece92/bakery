import 'package:bakery_flutter/providers/product_provider.dart';
import 'package:bakery_flutter/providers/qrlogin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:provider/provider.dart';

class TableWelcomeScreen extends StatefulWidget {
  final String? tableId;
  final String? businessId;

  const TableWelcomeScreen({
    super.key,
    this.tableId,
    this.businessId,
  });

  @override
  State<TableWelcomeScreen> createState() => _TableWelcomeScreenState();
}

class _TableWelcomeScreenState extends State<TableWelcomeScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // ── ENTRY POINT ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  void _checkSession() {
    final storage    = LocalStorageService.instance;
    final token      = storage.getSessionToken();
    final isBusiness = storage.getIsBusinessSession();

    debugPrint('====================================');
    debugPrint('SESSION CHECK — TableWelcomeScreen');
    debugPrint('tableId(url)   : ${widget.tableId}');
    debugPrint('businessId(url): ${widget.businessId}');
    debugPrint('token(storage) : $token');
    debugPrint('isBusiness     : $isBusiness');
    debugPrint('====================================');

    // CASE 1: QR params detected in URL
    if (widget.tableId != null && widget.businessId != null) {
      debugPrint('CASE 1: QR params in URL → _handleQRLogin()');
      _handleQRLogin();
      return;
    }

    // CASE 2: Business session exists in storage
    if (token != null && isBusiness) {
      debugPrint('CASE 2: Business session in storage → _verifyToken()');
      _verifyToken(isBusinessSession: true);
      return;
    }

    // CASE 3: Customer session exists in storage
    if (token != null && !isBusiness) {
      debugPrint('CASE 3: Customer session in storage → _verifyToken()');
      _verifyToken(isBusinessSession: false);
      return;
    }

    // CASE 4: Nothing exists — show UI normally
    debugPrint('CASE 4: No session → show UI normally');
  }

  // ── CASE 1: QR Login ───────────────────────────────────────────────────────
  Future<void> _handleQRLogin() async {
    debugPrint('--- _handleQRLogin START ---');
    debugPrint('tableId    : ${widget.tableId}');
    debugPrint('businessId : ${widget.businessId}');

    setState(() { _isLoading = true; _errorMessage = null; });

    final provider = context.read<QRLoginProvider>();

    await provider.login(
      businessId: widget.businessId!,
      tableName:  widget.tableId!,
    );

    if (provider.errorMessage == null && provider.data != null) {
      debugPrint('QR Login → SUCCESS → navigating to /home');
      if (mounted) context.go('/home');
    } else {
      debugPrint('QR Login → FAILED: ${provider.errorMessage}');
      setState(() {
        _isLoading    = false;
        _errorMessage = provider.errorMessage;
      });
    }
  }

  // ── CASE 2 & 3: Verify Token via fetchProducts ─────────────────────────────
  Future<void> _verifyToken({required bool isBusinessSession}) async {
    debugPrint('--- _verifyToken START ---');
    debugPrint('isBusinessSession : $isBusinessSession');

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // Use fetchProducts as token verification
      final productProvider = context.read<ProductProvider>();
      await productProvider.fetchProducts();

      if (productProvider.error != null) {
        throw Exception(productProvider.error);
      }

      // ON SUCCESS
      debugPrint('Token verify → SUCCESS → navigating to /home');
      if (mounted) context.go('/home');

    } catch (e) {
      debugPrint('Token verify → FAILED: $e');

      if (isBusinessSession) {
        // ── BUSINESS: no refresh, clear immediately ────
        debugPrint('Business session → NO refresh → clearing session');
        await LocalStorageService.instance.clearSession();
        setState(() {
          _isLoading    = false;
          _errorMessage = 'Your session has expired. Please scan the table QR again.';
        });

      } else {
        // ── CUSTOMER: try refresh token ────────────────
        debugPrint('Customer session → trying _refreshToken()');
        await _refreshToken();
      }
    }
  }

  // ── Refresh Token (Customer only) ──────────────────────────────────────────
  Future<void> _refreshToken() async {
    debugPrint('--- _refreshToken START --- (Customer only)');

    try {
      // TODO: your refresh token API call
      // final newToken = await AuthService.refreshToken();

      // ON SUCCESS
      debugPrint('Token refresh → SUCCESS → saving new token');
      await LocalStorageService.instance.saveSessionToken('new_token_from_api');
      debugPrint('New token saved → navigating to /home');
      if (mounted) context.go('/home');

    } catch (e) {
      debugPrint('Token refresh → FAILED: $e → clearing session');
      await LocalStorageService.instance.clearSession();
      setState(() {
        _isLoading    = false;
        _errorMessage = 'Your session has expired. Please login again.';
      });
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final tableId = LocalStorageService.instance.getAdminId() ?? widget.tableId;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide   = constraints.maxWidth > 500;
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
              // ── Background image ───────────────────────────────────────────
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

              // ── Gradient overlay ───────────────────────────────────────────
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

              // ── Loading overlay ────────────────────────────────────────────
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Bottom content ─────────────────────────────────────────────
              if (!_isLoading)
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

                            // ── Error Banner ───────────────────────────────
                            if (_errorMessage != null) ...[
                              _ErrorBanner(message: _errorMessage!),
                              const SizedBox(height: 20),
                            ],

                            // ── Tag pill ───────────────────────────────────
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

                            // ── Table badge ────────────────────────────────
                            if (tableId != null) ...[
                              _TableNumberBadge(tableNumber: 'Table $tableId'),
                              const SizedBox(height: 28),
                            ] else
                              const SizedBox(height: 28),

                            // ── Start Ordering (Guest) ─────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () async {
                                  debugPrint('====================================');
                                  debugPrint('USER ACTION  : Continue as Guest');
                                  debugPrint('SESSION TYPE : GUEST');
                                  debugPrint('====================================');
                                  await LocalStorageService.instance.saveSessionType('guest');
                                  if (mounted) context.go('/home');
                                },
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

                            const SizedBox(height: 12),

                            // ── Login with Account ─────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {
                                  debugPrint('====================================');
                                  debugPrint('USER ACTION  : Tapped Login with Account');
                                  debugPrint('Navigating to: /login');
                                  debugPrint('====================================');
                                  context.go('/login');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: const Text(
                                  'Login with Account',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── QR Hint ────────────────────────────────────
                            const _ScanQrHint(),

                            const SizedBox(height: 16),

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

// ── Error Banner ───────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan QR Hint ───────────────────────────────────────────────────────────

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

// ── Table Number Badge ─────────────────────────────────────────────────────

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

// ── Splash Check View ──────────────────────────────────────────────────────

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
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF1A1A1A)),
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

// ── Invalid QR View ────────────────────────────────────────────────────────

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