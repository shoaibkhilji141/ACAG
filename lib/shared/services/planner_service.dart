import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Talks to the Vigilant Site plan-generator API.
///
/// Same shape as the other services in this folder: static methods that throw
/// `Exception(message)`, which is what every screen already catches.
class PlannerService {
  static const _base =
      'https://yahya-mateen--vigilant-planner-fastapi-app.modal.run';

  // Set this only once the API key is switched on; leave empty until then.
  static const _apiKey = '9b3fe52fce7e1f4805898059f2732dfbc44a564209925f509e95af5345044fdc';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_apiKey.isNotEmpty) 'X-API-Key': _apiKey,
      };

  /// Wakes the server. The container sleeps after 15 seconds of no traffic and
  /// takes about 8 to come back — call this when the PLOT screen opens so it
  /// is awake by the time the engineer presses Generate. Never throws.
  static Future<void> wake() async {
    try {
      await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      // it will wake on the real request instead
    }
  }

  /// What this particular plot allows — call it when the ROOM screen opens
  /// and build the counters from the answer.
  static Future<Map<String, dynamic>> optionsForPlot({
    required double width,
    required double length,
    String unit = 'feet',
  }) async {
    final res = await http
        .get(
            Uri.parse(
                '$_base/options?width=$width&length=$length&unit=$unit'),
            headers: _headers)
        .timeout(const Duration(seconds: 60));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? 'Could not read the plot options');
    }
    return body;
  }

  /// Screens 1 and 2 in, Screen 3 out.
  static Future<Map<String, dynamic>> generateFloorPlans({
    required String unit,
    required double width,
    required double length,
    double? totalArea,
    required String geographicZone,
    required int bedrooms,
    required int bathrooms,
    int toilets = 0,
    int kitchens = 1,
    String? projectId,
  }) async {
    final res = await http
        .post(Uri.parse('$_base/module01/floor-plans'),
            headers: _headers,
            body: jsonEncode({
              'unit': unit,
              'width': width,
              'length': length,
              'total_area': totalArea,
              'geographic_zone': geographicZone,
              'bedrooms': bedrooms,
              'bathrooms': bathrooms,
              'toilets': toilets,
              'kitchens': kitchens,
              'project_id': projectId,
            }))
        .timeout(const Duration(seconds: 90));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? 'Could not generate plans');
    }
    return body;
  }

  /// Downloads an image from a URL and returns it as a base64 data URI string.
  /// Used when saving the chosen plan permanently — the API deletes files
  /// after 6 hours, so the app must download them before they expire.
  static Future<String?> downloadAsBase64(String url) async {
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return null;
      return 'data:image/png;base64,${base64Encode(res.bodyBytes)}';
    } catch (e) {
      debugPrint('downloadAsBase64 failed for $url: $e');
      return null;
    }
  }

  // ── Temporary result cache ───────────────────────────────────
  // The stitch navigation passes only the ProjectModel, not arbitrary data.
  // So the room screen stores the generation result here, and the floor plans
  // screen picks it up. Cleared after reading.

  static Map<String, dynamic>? _lastResult;

  static void cacheResult(Map<String, dynamic> result) => _lastResult = result;

  static Map<String, dynamic>? consumeResult() {
    final r = _lastResult;
    _lastResult = null;
    return r;
  }

  static Map<String, dynamic>? peekResult() {
    return _lastResult;
  }
}
