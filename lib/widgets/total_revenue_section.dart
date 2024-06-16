import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/stats_screen.dart';

class TotalRevenueSection extends StatefulWidget {
  final TextEditingController usernameController;

  TotalRevenueSection({required this.usernameController});

  @override
  _TotalRevenueSectionState createState() => _TotalRevenueSectionState();
}

class _TotalRevenueSectionState extends State<TotalRevenueSection> {
  DateTimeRange? _customDateRange;
  Future<double>? _revenueFuture;

  Future<double> _getCustomTotal(DateTimeRange dateRange) async {
    String username = widget.usernameController.text.trim();
    if (username.isEmpty) {
      return 0.0;
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('receipts')
        .where('servedBy', isEqualTo: username)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
        .get();

    double total = 0.0;
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var totalAmount = data['totalAmount'];
      if (totalAmount is double) {
        total += totalAmount;
      }
    }

    return total;
  }

  Widget _buildRevenueSortingOptions() {
    // Placeholder for sorting options - implement as needed
    return Text('Sort Options');
  }

  Widget _buildTotalRevenueSection() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ReceiptSearchScreen()));
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Employee Sale ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRevenueSortingOptions(),
                ],
              ),
              SizedBox(height: 10),
              FutureBuilder<double>(
                future: _revenueFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    double totalRevenue = snapshot.data ?? 0.0;
                    return Text(
                      'Total Revenue: ₵${totalRevenue.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18.0),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTotalRevenueSection();
  }
}
