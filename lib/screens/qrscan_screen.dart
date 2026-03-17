import 'dart:async';

import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:bakery_flutter/providers/qrlogin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;
  bool _torchOn = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        unawaited(_controller.start());
      case AppLifecycleState.inactive:
        unawaited(_controller.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    unawaited(_controller.dispose());
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned || _isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final rawValue = barcode!.rawValue!;
    debugPrint('QR scanned: $rawValue');

    final uri = Uri.tryParse(rawValue);
    if (uri == null) {
      _showError('Invalid QR code format.');
      return;
    }

    final businessId = uri.queryParameters['businessId'];
    final tableNumber = uri.queryParameters['tableNumber'];

    if (businessId == null ||
        businessId.isEmpty ||
        tableNumber == null ||
        tableNumber.isEmpty) {
      _showError('QR code is missing required data.');
      return;
    }

    setState(() {
      _hasScanned = true;
      _isProcessing = true;
      _errorMessage = null;
    });

    unawaited(_controller.stop());
    _login(businessId: businessId, tableName: tableNumber);
  }

  Future<void> _login({
    required String businessId,
    required String tableName,
  }) async {
    final provider = context.read<QRLoginProvider>();
    await provider.login(businessId: businessId, tableName: tableName);

    if (!mounted) return;

    if (provider.errorMessage != null) {
      setState(() {
        _errorMessage = provider.errorMessage;
        _isProcessing = false;
        _hasScanned = false;
      });
      provider.reset();
      unawaited(_controller.start());
    } else if (provider.data != null) {
      context.go('/home');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _hasScanned = false;
      _isProcessing = false;
    });
  }

  void _toggleTorch() {
    unawaited(_controller.toggleTorch());
    setState(() => _torchOn = !_torchOn);
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera feed
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),

            // Dark overlay + animated scan window
            _ScanOverlay(borderColor: context.colors.primary),

            // Top bar (back + title + torch)
            _buildTopBar(context),

            // Hint text below scan window
            _buildHintText(context),

            // Loading overlay
            if (_isProcessing) _buildLoadingOverlay(),

            // Error banner
            if (_errorMessage != null && !_isProcessing)
              _buildErrorBanner(context, bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _CircleIconButton(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Scan QR Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              _CircleIconButton(
                onTap: _toggleTorch,
                child: Icon(
                  _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _torchOn ? Colors.amber : Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintText(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final windowCenterY = screenHeight / 2 - 30;
    const windowHalfSize = 120.0;

    return Positioned(
      top: windowCenterY + windowHalfSize + 24,
      left: 0,
      right: 0,
      child: const Text(
        'Point your camera at the table QR code',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white60,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
            SizedBox(height: 16),
            Text(
              'Logging in…',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, double bottomPadding) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: bottomPadding + 32,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.shade800.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _errorMessage = null),
              child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable circle icon button ───────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleIconButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ── Scan window overlay (animated) ───────────────────────────────────────────

class _ScanOverlay extends StatefulWidget {
  final Color borderColor;
  const _ScanOverlay({required this.borderColor});

  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true); // bounces top → bottom → top

    _scanAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, _) {
        return CustomPaint(
          painter: _OverlayPainter(
            borderColor: widget.borderColor,
            scanProgress: _scanAnimation.value, // 0.0 = top edge, 1.0 = bottom edge
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

// ── Overlay painter ───────────────────────────────────────────────────────────

class _OverlayPainter extends CustomPainter {
  final Color borderColor;
  final double scanProgress;

  _OverlayPainter({
    required this.borderColor,
    required this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double windowSize = 240;
    final double cx = size.width / 2;
    final double cy = size.height / 2 - 30;

    final scanRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: windowSize,
      height: windowSize,
    );

    // ── Dark overlay with scan window cutout ──
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black54);

    // ── Subtle full border around scan window ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(12)),
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // ── Corner brackets ──
    final bracketPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double len = 28;

    void drawCorner(Offset corner, double dx, double dy) {
      canvas.drawLine(corner, corner.translate(dx, 0), bracketPaint);
      canvas.drawLine(corner, corner.translate(0, dy), bracketPaint);
    }

    drawCorner(scanRect.topLeft, len, len);
    drawCorner(scanRect.topRight, -len, len);
    drawCorner(scanRect.bottomLeft, len, -len);
    drawCorner(scanRect.bottomRight, -len, -len);

    // ── Animated scan line ──
    // Clip drawing to stay inside the scan window only
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(12)),
    );

    final double lineY = scanRect.top + scanProgress * windowSize;
    const double fadePadding = 16.0;

    // Soft glow layer behind the line
    final glowPaint = Paint()
      ..color = borderColor.withOpacity(0.10)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        scanRect.left + fadePadding,
        lineY - 8,
        windowSize - fadePadding * 2,
        16,
      ),
      glowPaint,
    );

    // Main scan line
    canvas.drawLine(
      Offset(scanRect.left + fadePadding, lineY),
      Offset(scanRect.right - fadePadding, lineY),
      Paint()
        ..color = borderColor.withOpacity(0.85)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) =>
      old.borderColor != borderColor || old.scanProgress != scanProgress;
}