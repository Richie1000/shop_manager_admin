import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_manager_admin/screens/addEmployeeScreen.dart';
import 'package:shop_manager_admin/screens/detailsStatsScreen.dart';

import '../providers/auth.dart';
import '../widgets/grid_item.dart';
import 'add_product_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/homePage';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final numColumns = (screenWidth / 200).round();
    final gridTitle = [
      "Sale",
      "Add Product",
      "Stocks",
      "check Receipts",
      "Logout",
      "Add Employee",
    ];
    final assetName = ["cart", "stats", "stock", "receipts", "logout","stats",];

    Future<void> logout() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.signOut();
    }

    pushSalesScreen() {
      //pushScreen
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => SalesScreen()));
    }

    pushStatsScreen() {
      //pushScreen
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AddProductScreen()));
    }

    pushStocksScreen() {
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => StocksScreen()));
      // //Navigator.pushReplacementNamed(context, '/stocksScreen');
      // //pushScreen
    }
    pushAddEmployeeScreen(){
        Navigator.push(
           context, MaterialPageRoute(builder: (context) => Addemployeescreen()));
    }

    pushReceiptsScreen() {
      // //pushScreen
      // Navigator.push(
         //  context, MaterialPageRoute(builder: (context) => ()));
    }

    List<Function()> listOfFunctions = [
      pushSalesScreen,
      pushStatsScreen,
      pushStocksScreen,
      pushReceiptsScreen,
      logout,
      pushAddEmployeeScreen,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: Column(
        children: [
          // Card displaying today's date and total amount
          Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left column displaying today's date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        FutureBuilder<String>(
                          future: _getFormattedDate(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                snapshot.data!,
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    // Right column displaying total amount of receipts
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailStatsScreen()));
                      },
                      child: StreamBuilder<double>(
                        stream: getTodayTotal(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            double totalAmount = snapshot.data ?? 0.0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '\$$totalAmount',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ]),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: gridTitle.length,
              itemBuilder: (context, index) {
                return GridItem(
                  title: gridTitle[index],

                  //subtitle: '',
                  //icon: Icon(Icons.)
                  onTap: () {
                    // Call the corresponding function from listOfFunctions
                    listOfFunctions[index]();
                  },
                  lottieAsset: 'assets/animations/${assetName[index]}.json',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to format date
  Future<String> _getFormattedDate() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate;
  }

  // Function to get total amount of receipts for today
  Future<double> _getTotalReceiptsAmount() async {
    DateTime today = DateTime.now();
    DateTime startOfToday = DateTime(today.year, today.month, today.day);
    DateTime endOfToday =
        DateTime(today.year, today.month, today.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('receipts')
        .where('date', isGreaterThanOrEqualTo: startOfToday)
        .where('date', isLessThanOrEqualTo: endOfToday)
        .get();

    double totalAmount = 0;
    snapshot.docs.forEach((doc) {
      totalAmount += doc['totalAmount'] as double;
    });

    return totalAmount;
  }

  Stream<double> getTodayTotal() {
    // Get today's date formatted as dd/MM/yyyy
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);

    // Remove all slashes from the formatted date
    String dateWithoutSlashes = formattedDate.replaceAll('/', '');

    // Reference to the document with the modified date as the ID
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('statistics')
        .doc(dateWithoutSlashes);

    // Return a stream of the total field
    return docRef.snapshots().map((docSnapshot) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        // Cast the data to a map
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // Return the total field as a double
        return data['total']?.toDouble() ?? 0.0;
      } else {
        // If the document doesn't exist, return 0.0
        return 0.0;
      }
    });
  }
}
