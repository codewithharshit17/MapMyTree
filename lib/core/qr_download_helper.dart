import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QrDownloadHelper {
  /// Generate QR code image as PNG and trigger system share sheet for download/sharing.
  static Future<void> downloadOrShareQrCode(
      BuildContext context, String qrData, String treeId) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw 'Invalid QR code validation status';
      }

      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF1B4332),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF1B4332),
        ),
        gapless: true,
      );

      // Generate the image canvas
      final image = await painter.toImage(400);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw 'Failed to convert QR code painter to image bytes';
      }
      final bytes = byteData.buffer.asUint8List();

      // Write image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/QR_$treeId.png');
      await file.writeAsBytes(bytes);

      // Trigger the native platform Share sheet (which includes options to "Save Image", "Send", etc.)
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: 'QR Code for Tree $treeId',
        text: 'Here is the QR code for Tree ID: $treeId',
      ));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code image shared/ready to save!'),
            backgroundColor: Color(0xFF1B4332),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating or exporting QR Code: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving QR code: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
