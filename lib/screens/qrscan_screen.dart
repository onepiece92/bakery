import 'dart:async';

import 'package:bakery_flutter/extensions/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  // ── Lifecycle ────────────────────────────────────────────────

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
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _hasScanned = true);
    unawaited(_controller.stop());

    final value = barcode!.rawValue!;
    debugPrint('QR scanned: $value');

    if (mounted) Navigator.of(context).pop(value);
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
       
        ],
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
    // title: Text(
    //   'Scan QR Code',
    //   style: context.text.headlineLarge?.copyWith(color: Colors.white),
    // ),
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