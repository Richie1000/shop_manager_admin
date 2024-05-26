import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptSearchScreen extends StatefulWidget {
  @override
  _ReceiptSearchScreenState createState() => _ReceiptSearchScreenState();
}

class _ReceiptSearchScreenState extends State<ReceiptSearchScreen> {
  final TextEditingController _usernameController = TextEditingController();
  DateTimeRange? _dateRange;
  List<double> _totalAmounts = [];

  Future<void> _searchReceipts(String username) async {
    setState(() {
      _totalAmounts.clear();
    });

    if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a date range'),
      ));
      return;
    }

    DateTime startDateWithTime = _dateRange!.start;
    DateTime endDateWithTime = _dateRange!.end;

    // Set time to start of the day (00:00:00)
    startDateWithTime = DateTime(
        startDateWithTime.year, startDateWithTime.month, startDateWithTime.day);

    // Set time to end of the day (23:59:59)
    endDateWithTime = DateTime(endDateWithTime.year, endDateWithTime.month,
        endDateWithTime.day, 23, 59, 59);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('receipts')
        .where('servedBy', isEqualTo: username)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDateWithTime))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDateWithTime))
        .get();

    List<double> amounts = querySnapshot.docs
        .map<double?>((doc) =>
            (doc.data() as Map<String, dynamic>)['totalAmount'] as double?)
        .where((amount) => amount != null)
        .cast<double>()
        .toList();

    setState(() {
      _totalAmounts.addAll(amounts);
    });

    _calculateTotalSum();
  }

  double _calculateTotalSum() {
    double sum = 0.0;
    for (double amount in _totalAmounts) {
      sum += amount;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter Employee name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (picked != null) {
                  setState(() {
                    _dateRange = picked;
                  });
                }
              },
              child: Text('Select Date Range'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  _searchReceipts(username);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter a username'),
                  ));
                }
              },
              child: Text(
                'Search',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Total Sales:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '${_calculateTotalSum()}',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
