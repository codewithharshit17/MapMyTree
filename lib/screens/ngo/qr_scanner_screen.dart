import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'tree_info_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _scanned = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;
    if (state == AppLifecycleState.resumed) {
      _controller!.start();
    } else if (state == AppLifecycleState.paused) {
      _controller!.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    final rawValue = barcode.rawValue!;
    _scanned = true;
    _controller?.stop();

    // Support both full URL and plain ID formats
    // e.g. "https://mapmytree.app/tree/MMT-17451234-abc1"
    // e.g. "MMT-17451234-abc1"
    String treeId = rawValue;
    if (rawValue.contains('/tree/')) {
      treeId = rawValue.split('/tree/').last.trim();
    }

    if (treeId.isEmpty) {
      _showNotFound(rawValue);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TreeInfoScreen(treeId: treeId),
      ),
    );
  }

  void _showNotFound(String raw) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('❌ Invalid QR Code'),
        content: Text(
            'This QR code is not a MapMyTree tree QR.\n\nValue: $raw'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _scanned = false);
              _controller?.start();
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Tree QR Code'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_off : Icons.flash_on),
            onPressed: () {
              setState(() => _torchOn = !_torchOn);
              _controller?.toggleTorch();
            },
            tooltip: 'Toggle Torch',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller?.switchCamera(),
            tooltip: 'Flip Camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
          ),
          // Overlay
          _buildScanOverlay(),
          // Bottom hint
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Point camera at a MapMyTree QR Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The tree info will open automatically',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth * 0.65;
      final top = (constraints.maxHeight - size) / 2 - 30;
      final left = (constraints.maxWidth - size) / 2;

      return Stack(
        children: [
          // Dark overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.55),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Positioned(
                  top: top,
                  left: left,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scan frame corners
          Positioned(
            top: top,
            left: left,
            child: _buildCorners(size),
          ),
        ],
      );
    });
  }

  Widget _buildCorners(double size) {
    const cornerLen = 24.0;
    const cornerThick = 4.0;
    const color = Color(0xFF52B788);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top-left
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: cornerLen,
              height: cornerThick,
              color: color,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: cornerThick,
              height: cornerLen,
              color: color,
            ),
          ),
          // Top-right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: cornerLen,
              height: cornerThick,
              color: color,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: cornerThick,
              height: cornerLen,
              color: color,
            ),
          ),
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: cornerLen,
              height: cornerThick,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: cornerThick,
              height: cornerLen,
              color: color,
            ),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: cornerLen,
              height: cornerThick,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: cornerThick,
              height: cornerLen,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
