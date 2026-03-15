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
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
    await _controller.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned || _isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final rawValue = barcode!.rawValue!;
    debugPrint('QR scanned: $rawValue');

    // Parse the URL to extract businessId and tableNumber
    final uri = Uri.tryParse(rawValue);
    if (uri == null) {
      _showError('Invalid QR code format.');
      return;
    }

    final businessId = uri.queryParameters['businessId'];
    final tableNumber = uri.queryParameters['tableNumber'];

    if (businessId == null || businessId.isEmpty ||
        tableNumber == null || tableNumber.isEmpty) {
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
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            _ScanOverlay(borderColor: context.colors.primary),

            // Loading overlay
            if (_isProcessing) _buildLoadingOverlay(),

            // Error banner
            if (_errorMessage != null && !_isProcessing)
              _buildErrorBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black45,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Logging in…',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: MediaQuery.of(context).padding.bottom + 40,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.red.shade700.withOpacity(0.92),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _errorMessage = null),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: true,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: _toggleTorch,
          tooltip: 'Toggle torch',
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
          ),
          icon: Icon(
            _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            color: _torchOn ? Colors.amber : Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Scan window overlay ───────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  final Color borderColor;
  const _ScanOverlay({required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(borderColor: borderColor),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Color borderColor;
  _OverlayPainter({required this.borderColor});

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

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black54);

    final bracketPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double len = 24;

    void drawCorner(Offset corner, double dx, double dy) {
      canvas.drawLine(corner, corner.translate(dx, 0), bracketPaint);
      canvas.drawLine(corner, corner.translate(0, dy), bracketPaint);
    }

    drawCorner(scanRect.topLeft, len, len);
    drawCorner(scanRect.topRight, -len, len);
    drawCorner(scanRect.bottomLeft, len, -len);
    drawCorner(scanRect.bottomRight, -len, -len);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) =>
      old.borderColor != borderColor;
}