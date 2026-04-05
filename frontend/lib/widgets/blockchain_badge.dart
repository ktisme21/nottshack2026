import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlockchainBadge extends StatelessWidget {
  final String hash;
  final DateTime? timestamp;
  
  const BlockchainBadge({
    Key? key,
    required this.hash,
    this.timestamp,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Blockchain Verification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'VERIFIED',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Transaction Hash:',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            hash,
            style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
          ),
          SizedBox(height: 4),
          Text(
            'Network: Polygon Amoy Testnet',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          if (timestamp != null) ...[
            SizedBox(height: 4),
            Text(
              'Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp!)}',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
          SizedBox(height: 8),
          Text(
            'This hash proves the ESG data has not been tampered with since it was recorded on the blockchain.',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}