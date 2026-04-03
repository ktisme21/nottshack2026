import 'package:cloud_firestore/cloud_firestore.dart';

class StrayCat {
  final String id;
  final String name;
  final String color;
  final String location;
  final String specificSpot;
  final List<String> healthStatus;
  final String temperament;
  final String description;
  final int trustScore;
  final int feedCount;
  final DateTime reportedAt;
  final String status;
  final String? imageUrl;

  StrayCat({
    required this.id,
    required this.name,
    required this.color,
    required this.location,
    required this.specificSpot,
    required this.healthStatus,
    required this.temperament,
    required this.description,
    required this.trustScore,
    required this.feedCount,
    required this.reportedAt,
    required this.status,
    this.imageUrl,
  });

  factory StrayCat.fromMap(String id, Map<String, dynamic> map) {
    return StrayCat(
      id: id,
      name: map['name'] ?? 'Unknown',
      color: map['color'] ?? 'Unknown',
      location: map['location'] ?? 'Unknown',
      specificSpot: map['specificSpot'] ?? '',
      healthStatus: List<String>.from(map['healthStatus'] ?? []),
      temperament: map['temperament'] ?? 'Unknown',
      description: map['description'] ?? '',
      trustScore: map['trustScore'] ?? 70,
      feedCount: map['feedCount'] ?? 0,
      reportedAt: (map['reportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'active',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'location': location,
      'specificSpot': specificSpot,
      'healthStatus': healthStatus,
      'temperament': temperament,
      'description': description,
      'trustScore': trustScore,
      'feedCount': feedCount,
      'reportedAt': reportedAt,
      'status': status,
      'imageUrl': imageUrl,
    };
  }
}