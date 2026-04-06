import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl    = 'http://10.163.4.70:3000';
  static const String _apiKey     = 'esg-hackathon-2026';

  static const String blockchainApiUrl = '$_baseUrl/api/company';
  static const String satelliteApiUrl  = '$_baseUrl/api/satellite';
  static const String verifyApiUrl     = '$_baseUrl/api/verify';
  static const String reportApiUrl     = '$_baseUrl/api/report';

  // Shared headers for all requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
  };

  /// Submit ESG data to blockchain
  static Future<Map<String, dynamic>> submitToBlockchain({
    required String companyId,
    required String companyName,
    required String period,
    required Map<String, dynamic> supplierData,
    required Map<String, dynamic> manufacturerData,
    required Map<String, dynamic> logisticsData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(blockchainApiUrl),
        headers: _headers,
        body: jsonEncode({
          'companyId': companyId,
          'companyName': companyName,
          'period': period,
          'supplierData': supplierData,
          'manufacturerData': manufacturerData,
          'logisticsData': logisticsData,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Blockchain API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit to blockchain: $e');
    }
  }

  /// Fetch satellite ESG data for a location
  static Future<Map<String, dynamic>> fetchSatelliteData({
    required String companyId,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(satelliteApiUrl),
        headers: _headers,
        body: jsonEncode({
          'companyId': companyId,
          'lat': lat,
          'lng': lng,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Satellite API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch satellite data: $e');
    }
  }

  /// Verify satellite vs company claim
  static Future<Map<String, dynamic>> verifyESG({
    required int satelliteRecordIndex,
    required int companyRecordIndex,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(verifyApiUrl),
        headers: _headers,
        body: jsonEncode({
          'satelliteRecordIndex': satelliteRecordIndex,
          'companyRecordIndex': companyRecordIndex,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Verify API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to verify ESG: $e');
    }
  }

  /// Get full ESG report for a company
  static Future<Map<String, dynamic>> getReport(String companyId) async {
    final response = await http.get(
      Uri.parse('$reportApiUrl/$companyId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load report: ${response.body}');
    }
  }
}
