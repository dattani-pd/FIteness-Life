import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../controllers/controller.dart';
import '../../model/model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ==========================================
// BARCODE SCANNER SCREEN (mobile_scanner 7.x)
// ==========================================

class BarcodeScannerScreen extends StatefulWidget {
  static const pageId = "/BarcodeScannerScreen";
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  final NutritionController nutritionController = Get.find<NutritionController>();

  bool isProcessing = false;
  bool isTorchOn = false;
  String? scannedBarcode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      isProcessing = true;
      scannedBarcode = barcode.rawValue;
    });

    print('📱 Scanned barcode: ${barcode.rawValue}');

    await cameraController.stop();

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final foodDetail = await nutritionController.getFoodByBarcode(barcode.rawValue!);

    Get.back(); // Close loading

    if (foodDetail != null) {
      _showFoodDetailsDialog(foodDetail);
    } else {
      // Barcode not found (Themed Dialog)
      final bool isDark = Get.isDarkMode;
      Get.dialog(
        AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          title: Text('Not Found', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: Text(
            'No food found for barcode: ${barcode.rawValue}\n\nTry searching manually instead.',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back(); // Close scanner
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            isProcessing = false;
            scannedBarcode = null;
          });
          cameraController.start();
        }
      });
    }
  }

  void _toggleTorch() async {
    await cameraController.toggleTorch();
    setState(() {
      isTorchOn = !isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Theme Logic
    final bool isDark = Get.isDarkMode;
    // Note: We keep the main scaffold black for camera contrast, but theme the overlay button
    final Color buttonBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color buttonText = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black, // Keep black for camera immersion
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: isTorchOn ? Colors.yellow : Colors.grey,
            ),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            MobileScanner(
              controller: cameraController,
              onDetect: _onBarcodeDetected,
            ),

            // Scanning Overlay
            CustomPaint(
              painter: ScannerOverlay(),
              child: Container(),
            ),

            // Instructions & Results
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (scannedBarcode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '✓ Scanned',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scannedBarcode!,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Position barcode within the frame',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),

            // Manual Entry Button (Themed)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _showManualBarcodeEntry,
                  icon: Icon(Icons.keyboard, color: buttonText),
                  label: Text('Enter Manually', style: TextStyle(color: buttonText)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBg,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ THEMED Manual Entry Dialog
  void _showManualBarcodeEntry() {
    final TextEditingController barcodeController = TextEditingController();
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.grey[50]!;

    Get.dialog(
      AlertDialog(
        backgroundColor: bg,
        title: Text('Enter Barcode', style: TextStyle(color: text)),
        content: TextField(
          controller: barcodeController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: text),
          decoration: InputDecoration(
            hintText: 'Enter 13-digit barcode',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLength: 13,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final barcode = barcodeController.text.trim();
              if (barcode.isEmpty) return;

              Get.back();

              setState(() {
                isProcessing = true;
                scannedBarcode = barcode;
              });

              await cameraController.stop();

              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

              final foodDetail = await nutritionController.getFoodByBarcode(barcode);
              Get.back();

              if (foodDetail != null) {
                _showFoodDetailsDialog(foodDetail);
              } else {
                Get.snackbar(
                  'Not Found',
                  'No food found for barcode: $barcode',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                setState(() {
                  isProcessing = false;
                  scannedBarcode = null;
                });
                cameraController.start();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ THEMED Food Details Dialog
  void _showFoodDetailsDialog(FoodDetail details) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color codeBg = isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        details.foodName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: text),
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: codeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Barcode: $scannedBarcode',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.green.shade300 : Colors.green.shade700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Serving: ${details.servingSize}', style: TextStyle(color: subText)),
                      Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildNutritionRow('Calories', '${details.calories.toInt()}', 'kcal', Colors.red, text),
                      _buildNutritionRow('Protein', '${details.protein.toStringAsFixed(1)}', 'g', Colors.blue, text),
                      _buildNutritionRow('Carbs', '${details.carbs.toStringAsFixed(1)}', 'g', Colors.orange, text),
                      _buildNutritionRow('Fat', '${details.fat.toStringAsFixed(1)}', 'g', Colors.purple, text),
                      if (details.fiber > 0)
                        _buildNutritionRow('Fiber', '${details.fiber.toStringAsFixed(1)}', 'g', Colors.green, text),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          setState(() {
                            isProcessing = false;
                            scannedBarcode = null;
                          });
                          cameraController.start();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        child: Text('Scan Another', style: TextStyle(color: text)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.back();
                          Get.snackbar('Added', '${details.foodName} added to your plan', backgroundColor: Colors.green, colorText: Colors.white);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Add', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit, Color color, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: textColor))),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(width: 3),
          Text(unit, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.7))),
        ],
      ),
    );
  }
}

// Scanner Overlay (Doesn't need theming, keeps standard camera look)
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    final scanAreaWidth = size.width * 0.7;
    final scanAreaHeight = size.height * 0.3;
    final left = (size.width - scanAreaWidth) / 2;
    final top = (size.height - scanAreaHeight) / 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), paint);
    canvas.drawRect(Rect.fromLTWH(0, top, left, scanAreaHeight), paint);
    canvas.drawRect(Rect.fromLTWH(left + scanAreaWidth, top, left, scanAreaHeight), paint);
    canvas.drawRect(Rect.fromLTWH(0, top + scanAreaHeight, size.width, size.height - (top + scanAreaHeight)), paint);

    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight), const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}