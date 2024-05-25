import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:shop_manager_admin/screens/addEmployeeScreen.dart';


import 'package:uuid/uuid.dart';
import '../providers/cart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../screens/loading_screen.dart';

String getReceiptNumber() {
  // Get the current DateTime
  DateTime now = DateTime.now();

  // Define a list of month abbreviations
  const List<String> monthAbbreviations = [
    'Ja',
    'Fe',
    'Ma',
    'Ap',
    'Ma',
    'Ju',
    'Ju',
    'Au',
    'Se',
    'Oc',
    'No',
    'De'
  ];

  // Get the first two letters of the current month
  String month = monthAbbreviations[now.month - 1];

  // Format the current DateTime without hyphens, colons, and periods
  String formattedDateTime = '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';

  // Concatenate the month abbreviation with the formatted DateTime
  return '$month$formattedDateTime';
}

Future<Uint8List> generateAndSaveReceipt(
  List<CartItem> items,
  double totalAmount,
  String paymentMethod,
  BuildContext context,
) async {
  try {
    // Check product quantities before proceeding
    await checkProductQuantities(items);

    // Initialize PDF document
    final pdf = pw.Document();

    // Generate receipt number
    final String receiptNumber = getReceiptNumber();

    // Get current user ID
    final user = FirebaseAuth.instance.currentUser;
    final String userID = user!.uid;

    // Retrieve username from Firestore
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();
    final String username = userData['username'];

    final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Add page to PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Add receipt header
            pw.Text(
              'Receipt #$receiptNumber', // Adding receipt number
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Items:'),
            // Add items with date
            pw.ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final currentDate = DateTime.now();
                return pw.Text(
                  '${item.product.name} - ${item.quantity} x \$${item.product.sellingPrice.toStringAsFixed(2)} = \$${(item.quantity * item.product.sellingPrice).toStringAsFixed(2)}',
                );
              },
            ),

            pw.Divider(),
            // Add total amount
            pw.Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
            // Add payment method
            pw.Text('Payment Method: $paymentMethod'),
            // Add username
            pw.Text('\nServed by: $username on $currentDate'),
          ],
        ),
      ),
    );

    // Save PDF to local storage
    final pdfBytes = await pdf.save();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$receiptNumber.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    // Update product quantities in Firestore
    await updateProductQuantities(items);

    // Save PDF to Firestore Storage
    final downloadUrl = await savePdfToStorage(receiptNumber, pdfBytes);

    // Add transaction to "receipts" collection on Firestore
    await addTransactionToFirestore(
        receiptNumber, items, totalAmount, paymentMethod, downloadUrl);

    print('PDF saved to local storage: $filePath');

    return pdfBytes; // Return PDF bytes
  } catch (e) {
    CustomToast(message: e.toString());
    rethrow; // Rethrow the caught exception
  } finally {
    Navigator.of(context).pop(); // Ensure the loading dialog is dismissed
  }
}

Future<String> savePdfToStorage(
    String receiptNumber, Uint8List pdfBytes) async {
  // Save PDF to Firestore Storage

  final storageRef =
      FirebaseStorage.instance.ref().child('receipts/$receiptNumber.pdf');
  await storageRef.putData(pdfBytes);
  final downloadUrl = await storageRef.getDownloadURL();
  print('PDF saved to: $downloadUrl');
  return downloadUrl;
}

Future<void> addTransactionToFirestore(
  String receiptNumber,
  List<CartItem> items,
  double totalAmount,
  String paymentMethod,
  String pdfDownloadUrl,
) async {
  final firestore = FirebaseFirestore.instance;

  // Convert items to a list of maps
  final List<Map<String, dynamic>> itemsData =
      items.map((item) => item.toMap()).toList();

  // Add transaction to Firestore
  await firestore.collection('receipts').doc(receiptNumber).set({
    'items': itemsData,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'date': DateTime.now(),
    'pdfDownloadUrl': pdfDownloadUrl,
    'receiptsNumber': receiptNumber // Add download URL of PDF
  });

  // Add
  final DocumentReference statsRef =
      firestore.collection('statistics').doc('totalAmount');

  await firestore.runTransaction((transaction) async {
    DocumentSnapshot snapshot = await transaction.get(statsRef);
    double currentTotal = snapshot.exists ? snapshot['total'] : 0.0;

    double newTotal = currentTotal + totalAmount;
    transaction.set(statsRef, {'total': newTotal});

    // transaction.set(firestore.collection('payments').doc(), {
    //   'amount': totalAmount,
    //   'date': Timestamp.now(),
    // });
  });

  await updateStatistics(totalAmount);
}

Future<void> updateProductQuantities(List<CartItem> items) async {
  final firestore = FirebaseFirestore.instance;

  for (var item in items) {
    final productRef = firestore.collection('products').doc(item.product.id);

    // Use a transaction to ensure the update is atomic
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);
      if (!snapshot.exists) {
        throw Exception("Product does not exist!");
      }

      final currentQuantity = snapshot['quantity'] as int;
      final newQuantity = currentQuantity - item.quantity;

      transaction.update(productRef, {'quantity': newQuantity});
    });
  }
}

Future<void> checkProductQuantities(List<CartItem> items) async {
  final firestore = FirebaseFirestore.instance;

  for (var item in items) {
    final productRef = firestore.collection('products').doc(item.product.id);
    final snapshot = await productRef.get();

    if (!snapshot.exists) {
      throw Exception("Product does not exist!");
    }

    final currentQuantity = snapshot['quantity'] as int;

    if (currentQuantity < item.quantity) {
      CustomToast(
          message: "Insufficient Stock for product: ${item.product.name}");
      //Navigator.of(context).pop();
      throw Exception("Insufficient stock for product: ${item.product.name}");
    }
  }
}

Future<void> updateStatistics(double transactionTotal) async {
  // Get today's date formatted as dd/MM/yyyy
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  String dateWithoutSlashes = formattedDate.replaceAll('/', '');

  // Reference to the document with today's date as the ID
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('statistics')
      .doc(dateWithoutSlashes);

  // Get the document snapshot
  DocumentSnapshot docSnapshot = await docRef.get();

  // Check if the document exists
  if (docSnapshot.exists) {
    // Document exists, update the total field
    await docRef.update({'total': FieldValue.increment(transactionTotal)});
  } else {
    // Document does not exist, create it with the initial total
    await docRef.set({
      'total': transactionTotal,
      'date': formattedDate // Store the date for reference if needed
    });
  }
}
