// // ==========================================
// // WORKING IMAGE FOOD SCANNER
// // Uses Google Cloud Vision API (FREE TIER)
// // FILE: lib/screen/nutrition/image_food_scanner_screen.dart
// // ==========================================
//
// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import '../../controllers/nutrition_controller.dart';
//
// class ImageFoodScannerScreen extends StatefulWidget {
//   static const pageId = "/ImageFoodScannerScreen";
//   const ImageFoodScannerScreen({super.key});
//
//   @override
//   State<ImageFoodScannerScreen> createState() => _ImageFoodScannerScreenState();
// }
//
// class _ImageFoodScannerScreenState extends State<ImageFoodScannerScreen> {
//   final ImagePicker _picker = ImagePicker();
//
//   // ✅ YOUR GOOGLE CLOUD VISION API KEY (Get from: https://console.cloud.google.com/apis/credentials)
//   // OR use this temporary one for testing
//   static const String cloudVisionApiKey = 'AIzaSyAaAgHB9P4dEcSxz47V_inSicJxU92VtE8';
//
//   File? _selectedImage;
//   bool _isAnalyzing = false;
//   String? _identifiedFood;
//   String? _errorMessage;
//   List<String> _suggestions = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Food Image'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       backgroundColor: Colors.grey[50],
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Info Banner
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Take or upload a photo to identify the food',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.blue.shade900,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Image Preview
//             Container(
//               width: double.infinity,
//               height: 300,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey.shade300, width: 2),
//               ),
//               child: _selectedImage != null
//                   ? ClipRRect(
//                 borderRadius: BorderRadius.circular(14),
//                 child: Image.file(
//                   _selectedImage!,
//                   fit: BoxFit.cover,
//                 ),
//               )
//                   : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.image_outlined, size: 80, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No image selected',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Buttons
//             if (_selectedImage == null) ...[
//               _buildButton(
//                 icon: Icons.camera_alt,
//                 label: 'Take Photo',
//                 color: Colors.blue,
//                 onTap: _pickFromCamera,
//               ),
//               const SizedBox(height: 12),
//               _buildButton(
//                 icon: Icons.photo_library,
//                 label: 'Choose from Gallery',
//                 color: Colors.green,
//                 onTap: _pickFromGallery,
//               ),
//             ] else ...[
//               if (_isAnalyzing)
//                 Column(
//                   children: [
//                     const CircularProgressIndicator(),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Analyzing food...',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 )
//               else if (_suggestions.isNotEmpty)
//                 Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.green.shade200),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.lightbulb_outline, color: Colors.green.shade700),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'Select the food:',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           ..._suggestions.map((food) => Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   _identifiedFood = food;
//                                 });
//                                 _searchFood();
//                               },
//                               child: Container(
//                                 width: double.infinity,
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: Colors.green.shade300),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.restaurant, color: Colors.green.shade700, size: 20),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Text(
//                                         food,
//                                         style: const TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                     Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )).toList(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 )
//               else if (_errorMessage != null)
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.red.shade200),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.error_outline, color: Colors.red.shade700),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 _errorMessage!,
//                                 style: TextStyle(color: Colors.red.shade900),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: _analyzeFoodImage,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orange,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             icon: const Icon(Icons.refresh, color: Colors.white),
//                             label: const Text(
//                               'Try Again',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 else
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _analyzeFoodImage,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       icon: const Icon(Icons.analytics, color: Colors.white, size: 24),
//                       label: const Text(
//                         'Identify Food',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//
//               const SizedBox(height: 12),
//               OutlinedButton.icon(
//                 onPressed: _resetScanner,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Scan Another'),
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3), width: 2),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 24),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickFromCamera() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//           _identifiedFood = null;
//           _errorMessage = null;
//           _suggestions = [];
//         });
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to access camera: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> _pickFromGallery() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//           _identifiedFood = null;
//           _errorMessage = null;
//           _suggestions = [];
//         });
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to pick image: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   void _resetScanner() {
//     setState(() {
//       _selectedImage = null;
//       _identifiedFood = null;
//       _errorMessage = null;
//       _suggestions = [];
//     });
//   }
//
//   // ✅ WORKING SOLUTION: Google Cloud Vision API
//   Future<void> _analyzeFoodImage() async {
//     if (_selectedImage == null) return;
//
//     setState(() {
//       _isAnalyzing = true;
//       _errorMessage = null;
//       _suggestions = [];
//     });
//
//     try {
//       final imageBytes = await _selectedImage!.readAsBytes();
//       final base64Image = base64Encode(imageBytes);
//
//       final url = Uri.parse(
//           'https://vision.googleapis.com/v1/images:annotate?key=$cloudVisionApiKey'
//       );
//
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'requests': [
//             {
//               'image': {'content': base64Image},
//               'features': [
//                 {'type': 'LABEL_DETECTION', 'maxResults': 10},
//                 {'type': 'TEXT_DETECTION'},
//               ]
//             }
//           ]
//         }),
//       );
//
//       print('📡 Cloud Vision Response: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final responses = data['responses'] as List;
//
//         if (responses.isNotEmpty) {
//           final result = responses[0];
//
//           // Get labels
//           final labels = result['labelAnnotations'] as List?;
//           final detectedText = result['textAnnotations'] as List?;
//
//           List<String> foodSuggestions = [];
//
//           // Extract food-related labels
//           if (labels != null) {
//             for (var label in labels) {
//               final description = label['description'].toString();
//               final score = label['score'] as double;
//
//               if (score > 0.7) { // High confidence
//                 foodSuggestions.add(description);
//               }
//             }
//           }
//
//           // Extract text from package (if any)
//           if (detectedText != null && detectedText.isNotEmpty) {
//             final text = detectedText[0]['description'].toString();
//             final words = text.split('\n').where((w) => w.length > 3).toList();
//             foodSuggestions.addAll(words.take(3));
//           }
//
//           if (foodSuggestions.isEmpty) {
//             throw Exception('Could not identify food');
//           }
//
//           // Remove duplicates
//           foodSuggestions = foodSuggestions.toSet().toList();
//
//           setState(() {
//             _suggestions = foodSuggestions.take(5).toList();
//             _isAnalyzing = false;
//           });
//
//         } else {
//           throw Exception('No results from API');
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         throw Exception(errorData['error']['message'] ?? 'API Error');
//       }
//     } catch (e) {
//       print('❌ Error: $e');
//       setState(() {
//         _errorMessage = 'Failed to identify food. Try again.';
//         _isAnalyzing = false;
//       });
//     }
//   }
//
//   void _searchFood() {
//     if (_identifiedFood == null) return;
//
//     final controller = Get.find<NutritionController>();
//     Get.back();
//
//     Get.snackbar(
//       'Searching...',
//       'Looking for: $_identifiedFood',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//       icon: const Icon(Icons.search, color: Colors.white),
//     );
//
//     controller.searchFood(_identifiedFood!);
//   }
// }


// ==========================================
// FREE IMAGE FOOD SCANNER - NO API NEEDED
// Uses TensorFlow Lite + MobileNet (Local AI)
// FILE: lib/screen/nutrition/image_food_scanner_screen.dart
// ==========================================

/*
SETUP REQUIRED:
1. Add to pubspec.yaml:
   dependencies:
     tflite_flutter: ^0.10.4
     image: ^4.0.17

2. Download model file (food101.tflite) and labels (food101_labels.txt)
   and put in assets/models/ folder

3. Add to pubspec.yaml:
   flutter:
     assets:
       - assets/models/food101.tflite
       - assets/models/food101_labels.txt
*/
// ==========================================
// SIMPLEST IMAGE FOOD SCANNER
// User uploads image → Types food name → Search
// NO API, NO MODELS, NO SETUP - WORKS IMMEDIATELY
// ==========================================
// ==========================================
// IMAGE FOOD SCANNER - FREE HUGGING FACE API
// Upload image → Tap Identify → Get food name automatically
// NO SETUP, 100% FREE
// ==========================================


///working OCR
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'food_search_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart'; // ✅ Changed Import
import 'package:image_picker/image_picker.dart';
import 'food_search_screen.dart';


class FreeOCRScannerScreen extends StatefulWidget {
  const FreeOCRScannerScreen({super.key});

  @override
  State<FreeOCRScannerScreen> createState() => _FreeOCRScannerScreenState();
}

class _FreeOCRScannerScreenState extends State<FreeOCRScannerScreen> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // ✅ FREE KEY (Register at ocr.space for your own if this is slow)
  final String _apiKey = "K85276248788957";

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });
      _scanWithFreeOCR();
    }
  }

  Future<void> _scanWithFreeOCR() async {
    if (_image == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.ocr.space/parse/image'),
      );

      request.fields['apikey'] = _apiKey;
      request.fields['language'] = 'eng';
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var parsedResults = data['ParsedResults'];

        if (parsedResults != null && parsedResults.isNotEmpty) {
          String detectedText = parsedResults[0]['ParsedText'];

          // Simple cleanup to get the first meaningful line
          String foodName = detectedText.split('\n').firstWhere(
                  (line) => line.trim().length > 3,
              orElse: () => "Unknown"
          );

          Get.off(() => FoodSearchScreen(initialQuery: foodName));
        } else {
          Get.snackbar("Error", "No text found.");
        }
      } else {
        Get.snackbar("Error", "API Failed: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Free Scanner")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Scan Food (Free)"),
        ),
      ),
    );
  }
}



class SmartFoodScannerScreen extends StatefulWidget {
  const SmartFoodScannerScreen({super.key});

  @override
  State<SmartFoodScannerScreen> createState() => _SmartFoodScannerScreenState();
}

class _SmartFoodScannerScreenState extends State<SmartFoodScannerScreen> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final String _openAIKey = String.fromEnvironment('OPENAI_API_KEY');

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Resize image to speed up upload
        maxWidth: 600,    // Limit width to prevent memory crashes
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading = true;
        });
        _identifyFoodWithAI();
      }
    } catch (e) {
      print("Camera Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _identifyFoodWithAI() async {
    if (_image == null) return;

    try {
      // 1. Convert Image to Base64
      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // 2. OpenAI API Request
      var url = Uri.parse('https://api.openai.com/v1/chat/completions');

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini", // Cheap and Fast Vision Model
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Identify this food item. Return ONLY the food name (e.g., 'Banana', 'Milk', 'Fried Rice'). Do not write sentences. If it is not food, return 'Unknown'."
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image"
                  }
                }
              ]
            }
          ],
          "max_tokens": 20
        }),
      );

      // 3. Handle Result
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String foodName = data['choices'][0]['message']['content'].trim();

        print("🤖 AI Found: $foodName");

        // Remove punctuation like "."
        foodName = foodName.replaceAll(RegExp(r'[^\w\s]'), '');

        if (foodName.toLowerCase() != "unknown") {
          // ✅ Navigate to Search Screen
          Get.off(() => FoodSearchScreen(initialQuery: foodName));
        } else {
          Get.snackbar("Not Food", "Could not identify food object.");
        }
      } else {
        print("API Error: ${response.body}");
        if (response.statusCode == 429) {
          Get.snackbar("Quota Exceeded", "Please add \$5 credit to OpenAI Billing.");
        } else {
          Get.snackbar("Error", "Server Error: ${response.statusCode}");
        }
      }

    } catch (e) {
      print("Network Error: $e");
      Get.snackbar("Error", "Check internet connection.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Food Scanner"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: _isLoading
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 20),
            Text("Identifying Food...", style: TextStyle(fontSize: 16)),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_image!, height: 250, width: 250, fit: BoxFit.cover),
              )
            else
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fastfood, size: 70, color: Colors.red.shade300),
              ),

            const SizedBox(height: 40),

            // Camera Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text("Take Photo", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///working ML Kit


class ImageFoodScannerScreen extends StatefulWidget {
  static const pageId = "/ImageFoodScannerScreen";
  const ImageFoodScannerScreen({super.key});

  @override
  State<ImageFoodScannerScreen> createState() => _ImageFoodScannerScreenState();
}

class _ImageFoodScannerScreenState extends State<ImageFoodScannerScreen> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Lower confidence slightly to catch food items that aren't #1
  final ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.3));

  @override
  void dispose() {
    _imageLabeler.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading = true;
        });
        _identifyObjectInImage();
      }
    } catch (e) {
      print("❌ Camera Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _identifyObjectInImage() async {
    if (_image == null) return;

    try {
      final inputImage = InputImage.fromFile(_image!);
      final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);

      String detectedFoodName = "";

      // 🚫 IGNORE LIST: Backgrounds and generic terms
      final List<String> unwantedLabels = [
        "textile", "wood", "table", "hardwood", "flooring", "plywood",
        "linen", "fabric", "material", "pattern", "surface",
        "plate", "bowl", "cutlery", "spoon", "fork", "knife", "dishware",
        "food", "fruit", "vegetable", "produce", "recipe", "ingredient"
      ];

      print("🔍 Scanning Labels...");

      for (ImageLabel label in labels) {
        String text = label.label.toLowerCase();
        print("   -> Found: $text (${label.confidence})");

        // 1. If it's a background word, SKIP IT
        if (unwantedLabels.contains(text)) {
          print("      (Ignored: Background/Generic)");
          continue;
        }

        // 2. If it's NOT ignored, it's likely our food (e.g., Banana)
        detectedFoodName = label.label;
        print("      ✅ SELECTED: $detectedFoodName");
        break; // Stop looking, we found it!
      }

      // FALLBACK: If we ignored everything, just take the top result
      if (detectedFoodName.isEmpty && labels.isNotEmpty) {
        detectedFoodName = labels.first.label;
      }

      if (detectedFoodName.isNotEmpty) {
        // ✅ Go to Search
        Get.off(() => FoodSearchScreen(initialQuery: detectedFoodName));
      } else {
        Get.snackbar("Try Again", "Could not identify object. Get closer to the food.", backgroundColor: Colors.orange, colorText: Colors.white);
      }

    } catch (e) {
      print("❌ ML Kit Error: $e");
      Get.snackbar("Error", "Failed to process image.", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("Scan Food", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_image!, height: 300, fit: BoxFit.cover),
              )
            else
              Icon(Icons.camera_alt_outlined, size: 100, color: iconColor),

            const SizedBox(height: 30),

            // Take Photo Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text("Take Photo", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Gallery Button (Optional, but good UX)
            SizedBox(
              width: 200,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library, color: textColor),
                label: Text("Upload from Gallery", style: TextStyle(color: textColor, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class GeminiScannerScreen extends StatefulWidget {
  const GeminiScannerScreen({super.key});

  @override
  State<GeminiScannerScreen> createState() => _GeminiScannerScreenState();
}

class _GeminiScannerScreenState extends State<GeminiScannerScreen> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // ✅ PASTE YOUR GOOGLE API KEY HERE (Starts with AIza...)
  final String _apiKey = "AIzaSyAaAgHB9P4dEcSxz47V_inSicJxU92VtE8";

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 40, // Lower quality for faster upload
        maxWidth: 800,    // Limit size
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading = true;
        });
        _identifyFoodWithHttp();
      }
    } catch (e) {
      print("Camera Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // ✅ NO PLUGINS - PURE HTTP REQUEST
  // ✅ USES OLDER RELIABLE MODEL (gemini-pro-vision)
  Future<void> _identifyFoodWithHttp() async {
    if (_image == null) return;

    try {
      // 1. Convert Image to Base64
      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // ⚠️ CHANGED URL: Using 'gemini-pro-vision' (Old Reliable)
      final Uri url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$_apiKey');

      // 3. Construct the JSON Body
      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": "Identify this food item. Return ONLY the specific name (e.g., 'Banana', 'Apple', 'Fried Rice'). Do not write sentences. If it is not food, return 'Unknown'."
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      };

      // 4. Send Request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // 5. Handle Response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Navigate the JSON to find the text
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null) {

          String foodName = data['candidates'][0]['content']['parts'][0]['text'];
          foodName = foodName.trim().replaceAll(RegExp(r'[^\w\s]'), ''); // Remove punctuation

          print("🤖 API Response: $foodName");

          if (foodName.toLowerCase() != "unknown") {
            Get.off(() => FoodSearchScreen(initialQuery: foodName));
          } else {
            Get.snackbar("Not Recognized", "Could not identify food.", backgroundColor: Colors.orange);
          }
        }
      } else {
        print("❌ API Error: ${response.body}");
        // ⚠️ If even this fails, check the error message in the console
        Get.snackbar("Error", "Server Error: ${response.statusCode}");
      }

    } catch (e) {
      print("❌ Network Error: $e");
      Get.snackbar("Connection Error", "Check internet connection.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Food")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_image!, height: 250, fit: BoxFit.cover),
              )
            else
              const Icon(Icons.camera_alt, size: 80, color: Colors.grey),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text("Take Photo"),
            ),
          ],
        ),
      ),
    );
  }
}