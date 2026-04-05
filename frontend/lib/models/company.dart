import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String id;
  final String name;
  final String industry;
  final int totalReports;
  final double avgEsgScore;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    required this.industry,
    required this.totalReports,
    required this.avgEsgScore,
    required this.createdAt,
  });

  factory Company.fromFirestore(Map<String, dynamic> data, String id) {
    return Company(
      id: id,
      name: data['name'] ?? 'Unknown',
      industry: data['industry'] ?? 'Unknown',
      totalReports: data['totalReports'] ?? 0,
      avgEsgScore: (data['avgEsgScore'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'industry': industry,
      'totalReports': totalReports,
      'avgEsgScore': avgEsgScore,
      'createdAt': createdAt,
    };
  }
}