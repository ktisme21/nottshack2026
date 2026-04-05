import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/stray_cat.dart';
import '../services/database_service.dart';


class CatDetailScreen extends StatefulWidget {
  final String catId;
  
  const CatDetailScreen({required this.catId});
  
  @override
  _CatDetailScreenState createState() => _CatDetailScreenState();
}

class _CatDetailScreenState extends State<CatDetailScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<StrayCat?> _catFuture;
  
  @override
  void initState() {
    super.initState();
    _catFuture = _db.getStrayById(widget.catId);
  }
  
  Future<void> _recordFeeding() async {
    final foodType = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('What did you feed?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.restaurant),
              title: Text('Dry food'),
              onTap: () => Navigator.pop(context, 'Dry food'),
            ),
            ListTile(
              leading: Icon(Icons.restaurant),
              title: Text('Wet food'),
              onTap: () => Navigator.pop(context, 'Wet food'),
            ),
            ListTile(
              leading: Icon(Icons.water_drop),
              title: Text('Water'),
              onTap: () => Navigator.pop(context, 'Water'),
            ),
          ],
        ),
      ),
    );
    
    if (foodType != null) {
      final nameController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Your name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Record Feeding'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        await _db.recordFeeding(
          widget.catId,
          foodType,
          nameController.text.isEmpty ? 'Anonymous' : nameController.text,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🍽️ Feeding recorded! Thank you for helping!'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _catFuture = _db.getStrayById(widget.catId);
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cat Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _catFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading cat details'));
          }
          
          final cat = snapshot.data!;
          if (cat == null) {
            return Center(child: Text('Cat not found'));
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(cat),
                SizedBox(height: 20),
                _buildInfoCard(cat),
                SizedBox(height: 20),
                _buildFeedingButton(),
                SizedBox(height: 20),
                _buildFeedingHistory(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeader(StrayCat cat) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.pets, size: 60, color: Colors.white),
          SizedBox(height: 12),
          Text(
            cat.name,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Trust Score: ${cat.trustScore}%',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(StrayCat cat) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Information',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.palette, 'Color', cat.color),
            _buildInfoRow(Icons.psychology, 'Temperament', cat.temperament),
            _buildInfoRow(Icons.location_on, 'Location', cat.location),
            if (cat.specificSpot.isNotEmpty)
              _buildInfoRow(Icons.push_pin, 'Specific Spot', cat.specificSpot),
            _buildInfoRow(Icons.calendar_today, 'Reported', dateFormat.format(cat.reportedAt)),
            _buildInfoRow(Icons.restaurant, 'Times Fed', '${cat.feedCount}'),
            if (cat.description.isNotEmpty)
              _buildInfoRow(Icons.description, 'Description', cat.description),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green),
          SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Widget _buildFeedingButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _recordFeeding,
        icon: Icon(Icons.restaurant),
        label: Text('Record Feeding', style: GoogleFonts.poppins(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
  
  Widget _buildFeedingHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feeding History',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        StreamBuilder(
          stream: _db.getFeedingHistory(widget.catId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            
            final feedings = snapshot.data!;
            
            if (feedings.isEmpty) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('No feeding records yet. Be the first to help!'),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: feedings.length,
              itemBuilder: (context, index) {
                final feeding = feedings[index];
                final timestamp = (feeding['timestamp'] as Timestamp?)?.toDate();
                final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
                
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.restaurant, color: Colors.green),
                    title: Text(feeding['foodType'] ?? 'Unknown'),
                    subtitle: Text('By: ${feeding['reporterName'] ?? 'Anonymous'}'),
                    trailing: timestamp != null
                        ? Text(dateFormat.format(timestamp), style: TextStyle(fontSize: 11))
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}