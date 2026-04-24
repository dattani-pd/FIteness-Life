import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// WooCommerce REST API configuration for fitnessislife.org
/// Set your keys in WooCommerce: WP Admin → WooCommerce → Settings → Advanced → REST API
const String _baseUrl = 'https://fitnessislife.org/wp-json/wc/v3/products';
const int _packagesCategoryId = 19;

/// Replace with your WooCommerce Consumer Key and Consumer Secret (Basic Auth).
/// Keep these secure; do not commit real keys to public repos.
const String _consumerKey = 'ck_fa05111b2cecaa8c23d305b321ab4093950e68eb';
const String _consumerSecret = 'cs_9b92e548d7d2635cbf6d6756b79dacc41961ce97';

/// Static list of high-quality gym/fitness/bodybuilding image URLs.
/// Use fm=jpg and w=500 so images are a reasonable size for plans and WooCommerce.
const List<String> defaultFitnessImageUrls = [
  'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=500&fm=jpg',
  'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=500&fm=jpg',
  'https://images.unsplash.com/photo-1581009146145-b5ef050c149e?auto=format&fit=crop&w=500&fm=jpg',
  'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?auto=format&fit=crop&w=500&fm=jpg',
  'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=500&fm=jpg',
  'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=500&fm=jpg',
];

/// Returns a random image URL from [defaultFitnessImageUrls] for saving to Firestore and syncing to WooCommerce.
String getRandomDefaultImageUrl() {
  if (defaultFitnessImageUrls.isEmpty) {
    print('[IMAGE URL] ❌ defaultFitnessImageUrls is EMPTY - no image will be used');
    return '';
  }
  final String url = defaultFitnessImageUrls[Random().nextInt(defaultFitnessImageUrls.length)];
  print('[IMAGE URL] ✅ Generated random image URL: $url');
  return url;
}

/// Result of syncing a plan to the website.
class WooCommerceSyncResult {
  final bool success;
  final int? statusCode;
  final String? message;
  final String? productId;

  const WooCommerceSyncResult({
    required this.success,
    this.statusCode,
    this.message,
    this.productId,
  });

  factory WooCommerceSyncResult.success(int statusCode, [String? productId]) {
    return WooCommerceSyncResult(
      success: true,
      statusCode: statusCode,
      productId: productId,
    );
  }

  factory WooCommerceSyncResult.failure(int? statusCode, String message) {
    return WooCommerceSyncResult(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  factory WooCommerceSyncResult.error(String message) {
    return WooCommerceSyncResult(success: false, message: message);
  }
}

/// Deletes a product from the website (WooCommerce). Use when a plan is deleted in the app.
/// [wooProductId] must be the WooCommerce product ID (e.g. from plan.wooProductId).
/// Returns true if delete succeeded (200/204) or product was already gone (404); false on other errors.
Future<bool> deletePlanFromWebsite(String wooProductId) async {
  if (wooProductId.trim().isEmpty) return true;
  if (_consumerKey == 'YOUR_CONSUMER_KEY' || _consumerSecret == 'YOUR_CONSUMER_SECRET') {
    print('[WooCommerce delete] API keys not configured');
    return false;
  }
  final credentials = utf8.encode('$_consumerKey:$_consumerSecret');
  final basicAuth = 'Basic ${base64Encode(credentials)}';
  final url = '$_baseUrl/${wooProductId.trim()}';
  final headers = <String, String>{
    'Authorization': basicAuth,
    'Content-Type': 'application/json',
  };
  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Request timed out'),
    );
    print('WooCommerce Delete Response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 204) return true;
    if (response.statusCode == 404) return true; // Already deleted on web
    return false;
  } catch (e) {
    print('[WooCommerce delete] Error: $e');
    return false;
  }
}

/// Fetches all product IDs in the Packages category (id 19) from WooCommerce.
Future<List<String>> getPackagesProductIds() async {
  if (_consumerKey == 'YOUR_CONSUMER_KEY' || _consumerSecret == 'YOUR_CONSUMER_SECRET') {
    return [];
  }
  final credentials = utf8.encode('$_consumerKey:$_consumerSecret');
  final basicAuth = 'Basic ${base64Encode(credentials)}';
  final headers = <String, String>{
    'Authorization': basicAuth,
    'Content-Type': 'application/json',
  };
  final List<String> ids = [];
  try {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: <String, String>{
        'category': _packagesCategoryId.toString(),
        'per_page': '100',
      },
    );
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return ids;
    final list = jsonDecode(response.body);
    if (list is! List) return ids;
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final id = item['id']?.toString();
        if (id != null && id.isNotEmpty) ids.add(id);
      }
    }
  } catch (e) {
    print('[WooCommerce getPackagesProductIds] Error: $e');
  }
  return ids;
}

/// Removes from the website any Package product whose ID is NOT in [firestoreWooProductIds].
/// Call with the list of wooProductId from all workout_plans so the web only shows Firebase-linked plans.
/// Returns the number of products deleted.
Future<int> removePackagesNotInFirestore(List<String> firestoreWooProductIds) async {
  final keepSet = firestoreWooProductIds.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  final webIds = await getPackagesProductIds();
  int deleted = 0;
  for (final id in webIds) {
    if (keepSet.contains(id)) continue;
    final ok = await deletePlanFromWebsite(id);
    if (ok) deleted++;
  }
  if (deleted > 0) {
    print('[WooCommerce] Removed $deleted package(s) not in Firebase');
  }
  return deleted;
}

/// Finds a product ID in the Packages category (id 19) whose name matches [productName].
/// Returns null if none found. Used to avoid creating duplicate products when wooProductId was lost.
Future<String?> _findProductIdByNameInPackages(String productName, String basicAuth) async {
  if (productName.trim().isEmpty) return null;
  try {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: <String, String>{
        'search': productName.trim(),
        'category': _packagesCategoryId.toString(),
        'per_page': '5',
      },
    );
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    final list = jsonDecode(response.body);
    if (list is! List || list.isEmpty) return null;
    final nameLower = productName.trim().toLowerCase();
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final name = item['name']?.toString().trim().toLowerCase() ?? '';
      if (name == nameLower) {
        final id = item['id']?.toString();
        if (id != null && id.isNotEmpty) {
          print('[WooCommerce] Found existing product by name: "$productName" id=$id');
          return id;
        }
      }
    }
  } catch (e) {
    print('[WooCommerce] findProductIdByName error: $e');
  }
  return null;
}

/// Static placeholder when plan has no custom image. Used for WooCommerce product image.
const String wooCommerceDefaultImageUrl =
    'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg';

/// Syncs a fitness plan to WordPress/WooCommerce as a Simple Product under the Packages category.
/// If [wooProductId] is provided, updates the existing product (PUT); otherwise creates a new one (POST).
/// When [wooProductId] is null, by default looks for an existing product with the same name and updates it.
/// Set [forceCreate] true to always create a new product (so each Firebase plan gets its own product on web).
///
/// [title] Product name (plan name).
/// [price] Regular price (e.g. "29" or "0" for free).
/// [description] Product description (plan description).
/// [imageUrl] Optional (currently not sent; images disabled).
/// [wooProductId] Optional WooCommerce product ID; if set, the product is updated instead of created.
/// [forceCreate] If true and no wooProductId, always POST a new product (do not find by name). Use when syncing all plans so 3 plans = 3 products.
Future<WooCommerceSyncResult> syncPlanToWebsite({
  required String title,
  required String price,
  required String description,
  String? imageUrl,
  String? wooProductId,
  bool forceCreate = false,
}) async {
  if (_consumerKey == 'YOUR_CONSUMER_KEY' || _consumerSecret == 'YOUR_CONSUMER_SECRET') {
    return WooCommerceSyncResult.error(
      'WooCommerce API keys not configured. Set _consumerKey and _consumerSecret in woocommerce_api.dart',
    );
  }

  final credentials = utf8.encode('$_consumerKey:$_consumerSecret');
  final basicAuth = 'Basic ${base64Encode(credentials)}';

  // Ensure name, regular_price, description are never null (use empty string or '0')
  final String name = title.trim().isEmpty ? '' : title.trim();
  final String regularPrice = price.toString().trim().isEmpty ? '0' : price.toString().trim();
  final String desc = description.trim().isEmpty ? '' : description.trim();

  // Use wooProductId if we have it. If not, only find by name when NOT forceCreate (so "sync all" creates one product per plan)
  String? effectiveId = (wooProductId != null && wooProductId.trim().isNotEmpty) ? wooProductId.trim() : null;
  if (effectiveId == null && name.isNotEmpty && !forceCreate) {
    effectiveId = await _findProductIdByNameInPackages(name, basicAuth);
  }
  final bool isUpdate = effectiveId != null && effectiveId.isNotEmpty;

  // Resolve image URL: use provided imageUrl if valid, otherwise static placeholder so Web always has an image
  final String? rawImage = imageUrl?.trim();
  final String imageToSend = (rawImage != null && rawImage.isNotEmpty)
      ? rawImage
      : wooCommerceDefaultImageUrl;

  // Base body: name, price, description, categories, and images array (WooCommerce expects images: [{ src: url }])
  final Map<String, dynamic> body = <String, dynamic>{
    'name': name,
    'type': 'simple',
    'regular_price': regularPrice,
    'description': desc,
    'categories': <Map<String, dynamic>>[
      <String, dynamic>{'id': _packagesCategoryId}
    ],
    'images': <Map<String, dynamic>>[
      <String, dynamic>{'src': imageToSend}
    ],
  };
  final String bodyJson = jsonEncode(body);
  final Map<String, String> headers = <String, String>{
    'Content-Type': 'application/json',
    'Authorization': basicAuth,
  };
  final String requestUrl = isUpdate ? '$_baseUrl/$effectiveId' : _baseUrl;

  try {
    final response = isUpdate
        ? await http.put(
            Uri.parse(requestUrl),
            headers: headers,
            body: bodyJson,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          )
        : await http.post(
            Uri.parse(requestUrl),
            headers: headers,
            body: bodyJson,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

    print('WooCommerce Response: ${response.body}');

    if (response.statusCode == 201) {
      String? productId;
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>?;
        productId = json?['id']?.toString();
      } catch (_) {}
      return WooCommerceSyncResult.success(response.statusCode, productId);
    }

    if (response.statusCode == 200 && isUpdate) {
      return WooCommerceSyncResult.success(response.statusCode, effectiveId);
    }

    final String message = response.body.isNotEmpty
        ? _tryParseErrorMessage(response.body) ?? response.body
        : 'HTTP ${response.statusCode}';
    return WooCommerceSyncResult.failure(response.statusCode, message);
  } on Exception catch (e) {
    return WooCommerceSyncResult.error('Network or API error: $e');
  } catch (e) {
    return WooCommerceSyncResult.error('Unexpected error: $e');
  }
}

String? _tryParseErrorMessage(String body) {
  try {
    final json = jsonDecode(body);
    if (json is Map<String, dynamic>) {
      return json['message'] as String? ?? json['code'] as String?;
    }
    if (json is List && json.isNotEmpty && json.first is Map) {
      final first = json.first as Map;
      return first['message'] as String? ?? first['code'] as String?;
    }
  } catch (_) {}
  return null;
}

/// Legacy function; prefer [syncPlanToWebsite] which returns a result.
@Deprecated('Use syncPlanToWebsite and handle WooCommerceSyncResult')
Future<void> createPlanInWordPress(String title, String price, String description) async {
  final result = await syncPlanToWebsite(
    title: title,
    price: price,
    description: description,
  );
  if (result.success) {
    print('Plan created on website!');
  } else {
    print('Failed: ${result.message}');
  }
}
