import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../models/stray_cat.dart';

class ReportStrayScreen extends StatefulWidget {
  @override
  _ReportStrayScreenState createState() => _ReportStrayScreenState();
}

class _ReportStrayScreenState extends State<ReportStrayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  final _locationController = TextEditingController();
  final _specificSpotController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<String> _selectedHealth = [];
  String _selectedTemperament = 'Cautious';
  bool _isSubmitting = false;
  
  final DatabaseService _db = DatabaseService();
  
  final List<String> _healthOptions = [
    'Needs food',
    'Injured',
    'Healthy',
    'Pregnant',
    'Has kittens',
  ];
  
  final List<String> _temperamentOptions = [
    'Very scared',
    'Shy',
    'Cautious',
    'Friendly',
    'Very friendly',
  ];
  
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    final stray = StrayCat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      color: _colorController.text,
      location: _locationController.text,
      specificSpot: _specificSpotController.text,
      healthStatus: _selectedHealth,
      temperament: _selectedTemperament,
      description: _descriptionController.text,
      trustScore: 100,
      feedCount: 0,
      reportedAt: DateTime.now(),
      status: 'active',
    );
    
    await _db.addStray(stray);
    
    setState(() => _isSubmitting = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Stray cat reported! Thank you for helping.'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Clear form
    _nameController.clear();
    _colorController.clear();
    _locationController.clear();
    _specificSpotController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedHealth = [];
      _selectedTemperament = 'Cautious';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Stray Cat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildBasicInfoSection(),
              SizedBox(height: 24),
              _buildLocationSection(),
              SizedBox(height: 24),
              _buildHealthSection(),
              SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.pets, size: 40, color: Colors.green.shade700),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help a stray cat',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your report helps others find and feed this cat',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic Information', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Cat Name',
            hintText: 'e.g., Orange, Patches',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.edit),
          ),
          validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _colorController,
          decoration: InputDecoration(
            labelText: 'Color/Markings',
            hintText: 'e.g., Orange tabby, Black and white',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.palette),
          ),
        ),
        SizedBox(height: 12),
        DropdownButtonFormField(
          value: _selectedTemperament,
          decoration: InputDecoration(
            labelText: 'Temperament',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.psychology),
          ),
          items: _temperamentOptions.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (value) => setState(() => _selectedTemperament = value!),
        ),
      ],
    );
  }
  
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Area/Location',
            hintText: 'e.g., Central Park, Near Starbucks',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (v) => v!.isEmpty ? 'Please enter location' : null,
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _specificSpotController,
          decoration: InputDecoration(
            labelText: 'Specific Spot',
            hintText: 'e.g., Under red car, Behind dumpster',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.push_pin),
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Any distinguishing features or behaviors...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
  
  Widget _buildHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Health Status', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _healthOptions.map((status) {
            return FilterChip(
              label: Text(status),
              selected: _selectedHealth.contains(status),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedHealth.add(status);
                  } else {
                    _selectedHealth.remove(status);
                  }
                });
              },
              selectedColor: Colors.green.shade100,
              checkmarkColor: Colors.green,
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(color: Colors.white)
            : Text('Report Stray Cat', style: GoogleFonts.poppins(fontSize: 16)),
      ),
    );
  }
}