import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../services/product_api_service.dart';
import '../widgets/manual_barcode_sheet.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  static const double _windowWidth = 280;
  static const double _windowHeight = 170;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  bool _hasResult = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasResult) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && ProductApiService.isValidBarcode(value)) {
        _hasResult = true;
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop(value);
        return;
      }
    }
  }

  Future<void> _typeBarcode() async {
    await _controller.stop();
    if (!mounted) return;
    final code = await showManualBarcodeSheet(context);
    if (!mounted) return;
    if (code != null) {
      _hasResult = true;
      Navigator.of(context).pop(code);
    } else {
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final window = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(const Offset(0, -40)),
      width: _windowWidth,
      height: _windowHeight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              scanWindow: window,
              errorBuilder: (context, error) => _PermissionView(
                message:
                    error.errorCode == MobileScannerErrorCode.permissionDenied
                    ? 'Barkod taramak için kamera izni gerekiyor.'
                    : 'Kamera başlatılamadı.',
                onTypeBarcode: _typeBarcode,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ScanOverlayPainter(window, colors.accent),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Kapat',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _controller,
                        builder: (context, state, _) => CircleIconButton(
                          icon: state.torchState == TorchState.on
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          tooltip: 'El feneri',
                          onPressed: state.torchState == TorchState.unavailable
                              ? null
                              : _controller.toggleTorch,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Barkodu çerçevenin içine hizala',
                    style: textStyles.titleSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: _typeBarcode,
                    icon: const Icon(Icons.dialpad_rounded, size: 18),
                    label: const Text('Barkodu elle yaz'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.textPrimary,
                      textStyle: textStyles.labelLarge,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter(this.window, this.accent);

  final Rect window;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(
      window,
      const Radius.circular(AppRadius.lg),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(frame),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = accent,
    );
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) =>
      oldDelegate.window != window || oldDelegate.accent != accent;
}

class _PermissionView extends StatelessWidget {
  const _PermissionView({required this.message, required this.onTypeBarcode});

  final String message;
  final VoidCallback onTypeBarcode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.no_photography_rounded,
                size: 48,
                color: colors.textMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.textStyles.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onTypeBarcode,
                icon: const Icon(Icons.dialpad_rounded, size: 18),
                label: const Text('Barkodu elle yaz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
