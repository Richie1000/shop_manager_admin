import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import '../utils/styles.dart';

class DetailStatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topSectionHeight = screenHeight * 0.15;
    final DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Stats'),
      ),
      body: Column(
        children: [
          // Top Section for Total Amount and Today's Date
          Container(
            height: topSectionHeight,
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildGridItem(
                    'Today\'s Date', DateFormat('dd/MM/yyyy').format(today)),
                _buildTotalAmountItem(),
              ],
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 2.0,
            ),
          ),
          // Bottom Section for Receipts
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('receipts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final receipts = snapshot.data!.docs;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: receipts.length,
                  itemBuilder: (context, index) {
                    final receipt = receipts[index];
                    final receiptData = receipt.data() as Map<String, dynamic>;
                    return _buildReceiptGridItem(receiptData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, String value) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Styles.headline2,
            ),
            Text(
              value,
              style: Styles.headline4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountItem() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('statistics')
          .doc('totalAmount')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildGridItem('Total Amount', 'Loading...');
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final totalAmount = data['total'].toString();
        return _buildGridItem('Total Amount', 'GHC:${totalAmount}');
      },
    );
  }

  Widget _buildReceiptGridItem(Map<String, dynamic> receiptData) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt No: ${receiptData['receiptsNumber']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
            Text(
              'Product: ${receiptData['items']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
            Text(
              'Date: ${receiptData['date'].toDate()}',
              style: TextStyle(fontSize: 14.0),
            ),
            Text(
              'Selling Price: \$${receiptData['totalAmount']}',
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }
}
