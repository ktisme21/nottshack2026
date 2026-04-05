import 'package:cloud_firestore/cloud_firestore.dart';

class ESGReport {
  final String id;
  final String companyId;
  final String companyName;
  final String period;
  final int esgScore;
  final double totalEmissions;
  final double price;
  final String blockchainHash;
  final bool isVerified;
  final DateTime createdAt;
  final Map<String, dynamic> breakdown;
  final String status; // pending, processed, failed

  ESGReport({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.period,
    required this.esgScore,
    required this.totalEmissions,
    required this.price,
    required this.blockchainHash,
    required this.isVerified,
    required this.createdAt,
    required this.breakdown,
    required this.status,
  });

  factory ESGReport.fromFirestore(Map<String, dynamic> data, String id) {
    return ESGReport(
      id: id,
      companyId: data['companyId'] ?? '',
      companyName: data['companyName'] ?? 'Unknown',
      period: data['period'] ?? '',
      esgScore: data['esgScore'] ?? 0,
      totalEmissions: (data['totalEmissions'] ?? 0).toDouble(),
      price: (data['price'] ?? 5.0).toDouble(),
      blockchainHash: data['blockchainHash'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      breakdown: Map<String, dynamic>.from(data['breakdown'] ?? {}),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'period': period,
      'esgScore': esgScore,
      'totalEmissions': totalEmissions,
      'price': price,
      'blockchainHash': blockchainHash,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'breakdown': breakdown,
      'status': status,
    };
  }
}