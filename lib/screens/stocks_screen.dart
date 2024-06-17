import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_manager_admin/screens/addEmployeeScreen.dart';
import 'package:shop_manager_admin/screens/loading_screen.dart';
import '../models/product.dart';
import '../providers/products.dart';

class StocksScreen extends StatefulWidget {
  static const routeName = '/stocksScreen';

  @override
  _StocksScreenState createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  String _searchQuery = '';

  String _selectedRole = "Viewer";

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(productProvider),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (_selectedRole == "Editor")
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add delete functionality here
                },
                child: Text("Delete"),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: productProvider.productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingScreen();
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Center(child: Text('Error fetching products'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Align(
                    alignment: Alignment.center,
                    child: Text('No products available'),
                  );
                } else {
                  final products = snapshot.data!
                      .where((product) => product.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Selling Price')),
                        DataColumn(label: Text('Buying Price')),
                        DataColumn(label: Text('UOM')),
                      ],
                      rows: products.map((product) {
                        return DataRow(cells: [
                          DataCell(Text(product.name)),
                          DataCell(Text(product.quantity.toString())),
                          DataCell(Text(
                              'GHS${product.sellingPrice.toStringAsFixed(2)}')),
                          DataCell(Text(
                              'GHS${product.buyingPrice.toStringAsFixed(2)}')),
                          DataCell(Text(product.uom)),
                        ]);
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final Products productProvider;

  ProductSearchDelegate(this.productProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: productProvider.productsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(product.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Selling Price: \$${product.sellingPrice.toStringAsFixed(2)}'),
                        Text(
                            'Buying Price: \$${product.buyingPrice.toStringAsFixed(2)}'),
                        Text('Quantity: ${product.quantity}'),
                        Text('UOM: ${product.uom}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
