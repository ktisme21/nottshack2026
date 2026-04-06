import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company.dart';
import '../models/esg_report.dart';
import '../models/purchase.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ============ COMPANIES ============
  
  Future<List<Company>> getCompanies() async {
    final snapshot = await _firestore.collection('companies').get();
    return snapshot.docs
        .map((doc) => Company.fromFirestore(doc.data(), doc.id))
        .toList();
  }
  
  Future<Company?> getCompany(String companyId) async {
    final doc = await _firestore.collection('companies').doc(companyId).get();
    if (doc.exists) {
      return Company.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }
  
  Future<void> addCompany(String name, String industry) async {
    await _firestore.collection('companies').add({
      'name': name,
      'industry': industry,
      'totalReports': 0,
      'avgEsgScore': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  // ============ RAW ESG DATA (Triggers Python Processing) ============
  
  Future<String> submitRawESGData({
    required String companyId,
    required String period,
    required Map<String, dynamic> supplierData,
    required Map<String, dynamic> manufacturerData,
    required Map<String, dynamic> logisticsData,
  }) async {
    final docRef = await _firestore.collection('raw_esg_data').add({
      'companyId': companyId,
      'period': period,
      'supplierData': supplierData,
      'manufacturerData': manufacturerData,
      'logisticsData': logisticsData,
      'status': 'pending',  // Python backend will process this
      'submittedAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }
  
  Stream<QuerySnapshot> getPendingRawData() {
    return _firestore
        .collection('raw_esg_data')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }
  
  // ============ VERIFIED REPORTS ============
  
  Stream<List<ESGReport>> getVerifiedReports() {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: 'verified')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ESGReport.fromFirestore(doc.data(), doc.id))
            .toList());
  }
  
  Future<ESGReport?> getReport(String reportId) async {
    final doc = await _firestore.collection('reports').doc(reportId).get();
    if (doc.exists) {
      return ESGReport.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }
  
  Stream<ESGReport?> streamReport(String reportId) {
    return _firestore
        .collection('reports')
        .doc(reportId)
        .snapshots()
        .map((doc) => doc.exists 
            ? ESGReport.fromFirestore(doc.data()!, doc.id) 
            : null);
  }
  
  // ============ PURCHASES ============
  
  Future<void> purchaseReport(String reportId, String investorId) async {
    await _firestore.collection('purchases').add({
      'reportId': reportId,
      'investorId': investorId,
      'amount': 5.00,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  Future<bool> hasPurchased(String reportId, String investorId) async {
    final query = await _firestore
        .collection('purchases')
        .where('reportId', isEqualTo: reportId)
        .where('investorId', isEqualTo: investorId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
  
  Stream<List<Purchase>> getPurchasesByInvestor(String investorId) {
    return _firestore
        .collection('purchases')
        .where('investorId', isEqualTo: investorId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Purchase.fromFirestore(doc.data(), doc.id))
            .toList());
  }
  
  // ============ COMPANY REPORTS ============
  
  Stream<List<ESGReport>> getCompanyReports(String companyId) {
    return _firestore
        .collection('reports')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ESGReport.fromFirestore(doc.data(), doc.id))
            .toList());
  }
  
  
  // ============ CREATE REPORT FROM ESG SUBMISSION ============
  
  Future<String> submitESGReport({
    required String companyId,
    required String companyName,
    required String period,
    required Map<String, dynamic> supplierData,
    required Map<String, dynamic> manufacturerData,
    required Map<String, dynamic> logisticsData,
    String? txHash,
    String? dataHash,
    double? totalCO2,
  }) async {
    // Calculate ESG score from supplier, manufacturer, and logistics data
    int esgScore = _calculateESGScore(supplierData, manufacturerData, logisticsData);
    
    // Calculate total emissions
    double totalEmissions = (supplierData['emissionReduction'] ?? 0).toDouble() +
        (manufacturerData['emissions'] ?? 0).toDouble() +
        (logisticsData['transportEmissions'] ?? 0).toDouble();
    
    // Breakdown by category
    Map<String, dynamic> breakdown = {
      'supplier': (supplierData['emissionReduction'] ?? 0).toDouble(),
      'manufacturer': (manufacturerData['emissions'] ?? 0).toDouble(),
      'logistics': (logisticsData['transportEmissions'] ?? 0).toDouble(),
    };
    
    // Create report in 'reports' collection
    final docRef = await _firestore.collection('reports').add({
      'companyId': companyId,
      'companyName': companyName,
      'period': period,
      'esgScore': esgScore,
      'totalEmissions': totalEmissions,
      'price': 5.00,
      'blockchainHash': txHash ?? 'pending', 
      'dataHash': dataHash ?? '', 
      'isVerified': txHash != null,
      'status': 'verified', // Immediately visible to investors
      'breakdown': breakdown,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }
  
  int _calculateESGScore(
    Map<String, dynamic> supplierData,
    Map<String, dynamic> manufacturerData,
    Map<String, dynamic> logisticsData,
  ) {
    // Simple ESG score calculation (0-100)
    int score = 50; // Base score
    
    // Supplier factors
    if ((supplierData['certifications'] ?? '').toString().isNotEmpty) {
      score += 15;
    }
    if ((supplierData['emissionReduction'] ?? 0) > 0) {
      score += 15;
    }
    
    // Manufacturer factors
    if ((manufacturerData['renewableEnergy'] ?? 0) > 0) {
      score += 15;
    }
    if ((manufacturerData['energyUsage'] ?? 0) < 1000) {
      score += 10;
    }
    
    // Logistics factors
    if ((logisticsData['distance'] ?? 0) < 5000) {
      score += 10;
    }
    
    return (score).clamp(0, 100);
  }
  
  // ============ UPDATE REPORT (for Python backend) ============
  
  Future<void> updateReportWithResults({
    required String rawDataId,
    required String reportId,
    required int esgScore,
    required double totalEmissions,
    required String blockchainHash,
    required Map<String, dynamic> breakdown,
  }) async {
    // Update the raw data status
    await _firestore.collection('raw_esg_data').doc(rawDataId).update({
      'status': 'processed',
      'processedAt': FieldValue.serverTimestamp(),
    });
    
    // Create the verified report
    await _firestore.collection('reports').doc(reportId).set({
      'companyId': await _getCompanyIdFromRawData(rawDataId),
      'companyName': await _getCompanyNameFromRawData(rawDataId),
      'period': await _getPeriodFromRawData(rawDataId),
      'esgScore': esgScore,
      'totalEmissions': totalEmissions,
      'price': 5.00,
      'blockchainHash': blockchainHash,
      'isVerified': true,
      'status': 'verified',
      'breakdown': breakdown,
      'createdAt': FieldValue.serverTimestamp(),
      'rawDataId': rawDataId,
    });
  }
  
  // Helper methods
  Future<String> _getCompanyIdFromRawData(String rawDataId) async {
    final doc = await _firestore.collection('raw_esg_data').doc(rawDataId).get();
    return doc.data()?['companyId'] ?? 'unknown';
  }
  
  Future<String> _getCompanyNameFromRawData(String rawDataId) async {
    final doc = await _firestore.collection('raw_esg_data').doc(rawDataId).get();
    final companyId = doc.data()?['companyId'];
    if (companyId != null) {
      final company = await getCompany(companyId);
      return company?.name ?? 'Unknown';
    }
    return 'Unknown';
  }
  
  Future<String> _getPeriodFromRawData(String rawDataId) async {
    final doc = await _firestore.collection('raw_esg_data').doc(rawDataId).get();
    return doc.data()?['period'] ?? 'Unknown';
  }
}