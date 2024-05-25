import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';


class ReceiptScreen extends StatefulWidget {
  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  Future<void> _searchAndOpenPdf(String receiptId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('receipts')
          .doc(receiptId)
          .get();

      if (docSnapshot.exists) {
        final pdfDownloadUrl = docSnapshot['pdfDownloadUrl'];
        print("Found Receipt!");
        print('The download Url: $pdfDownloadUrl');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(url: pdfDownloadUrl),
          ),
        );
      } else {
        print("Receipt Not Found!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Receipt Not Found!")),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Receipt Search'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter Receipt ID',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        final receiptId = _searchController.text.trim();
                        if (receiptId.isNotEmpty) {
                          _searchAndOpenPdf(receiptId);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String url;

  PdfViewerScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDF().fromUrl(
        url,
        placeholder: (progress) =>
            Center(child: CircularProgressIndicator(value: progress / 100)),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
