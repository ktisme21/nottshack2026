import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  final String id;
  final String reportId;
  final String investorId;
  final double amount;
  final DateTime timestamp;

  Purchase({
    required this.id,
    required this.reportId,
    required this.investorId,
    required this.amount,
    required this.timestamp,
  });

  factory Purchase.fromFirestore(Map<String, dynamic> data, String id) {
    return Purchase(
      id: id,
      reportId: data['reportId'] ?? '',
      investorId: data['investorId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}