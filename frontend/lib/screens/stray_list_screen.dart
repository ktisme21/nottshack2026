import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/stray_cat.dart';
import 'cat_detail_screen.dart';

class StrayListScreen extends StatelessWidget {
  final DatabaseService _db = DatabaseService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Strays', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.warning),
            onPressed: () => _showUrgentDialog(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _db.getActiveStrays(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          }
          
          final strays = snapshot.data!;
          
          if (strays.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No strays reported yet',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text('Be the first to report a stray cat!'),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: strays.length,
            itemBuilder: (context, index) {
              final cat = strays[index];
              return _buildCatCard(context, cat);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildCatCard(BuildContext context, StrayCat cat) {
    final needsFood = cat.healthStatus.contains('Needs food');
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CatDetailScreen(catId: cat.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: needsFood ? Colors.red.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      needsFood ? Icons.warning : Icons.pets,
                      color: needsFood ? Colors.red : Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '📍 ${cat.location}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Trust: ${cat.trustScore}%',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Details row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.palette, cat.color, Colors.purple),
                  _buildInfoChip(Icons.restaurant, 'Fed: ${cat.feedCount}x', Colors.orange),
                  _buildInfoChip(Icons.calendar_today, dateFormat.format(cat.reportedAt), Colors.blue),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Health tags
              if (cat.healthStatus.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: cat.healthStatus.map((status) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'Injured' || status == 'Needs food'
                            ? Colors.red.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
              
              if (cat.specificSpot.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.push_pin, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        cat.specificSpot,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
  
  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Search by Location'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Enter area name...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSearchResults(context, searchController.text);
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }
  
  void _showSearchResults(BuildContext context, String query) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Results for "$query"',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _db.searchByLocation(query),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final results = snapshot.data!;
                    if (results.isEmpty) {
                      return Center(child: Text('No strays found in this area'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return _buildCatCard(context, results[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showUrgentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.warning, size: 40, color: Colors.red),
                    SizedBox(height: 8),
                    Text(
                      'Urgent: Cats Needing Help',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('These cats need food or medical attention'),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _db.getUrgentStrays(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final urgent = snapshot.data!;
                    if (urgent.isEmpty) {
                      return Center(child: Text('No urgent cases right now'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: urgent.length,
                      itemBuilder: (context, index) {
                        return _buildCatCard(context, urgent[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}