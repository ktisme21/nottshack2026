import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String blockchainApiUrl = 'http://localhost:3000/api/company';

  /// Submit ESG data to blockchain via local API endpoint
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
        headers: {
          'Content-Type': 'application/json',
        },
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
}
