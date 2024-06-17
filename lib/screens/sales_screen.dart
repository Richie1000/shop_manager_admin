import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shop_manager_admin/screens/checkout_screen.dart';

import '../models/product.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _selectedPaymentMethod = 'Cash';

  @override
  void initState() {

    super.initState();
  }

  void _incrementQuantity(Product product) {
    final cart = Provider.of<Cart>(context, listen: false);
    cart.addItem(product, 1);
  }

  void _decrementQuantity(Product product) {
    final cart = Provider.of<Cart>(context, listen: false);
    cart.decrementItem(product);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(context, listen: false);
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
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
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('No items in the cart'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text(
                            '${item.quantity} x ₵:${item.product.sellingPrice.toStringAsFixed(2)} = ₵:${(item.quantity * item.product.sellingPrice).toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _decrementQuantity(item.product),
                            ),
                            Text(item.quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _incrementQuantity(item.product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => cart.removeItem(item.product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Total: ₵:${cart.totalAmount.toStringAsFixed(2)}'),
          ),
          DropdownButton<String>(
            value: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            items: <String>['Cash', 'Mobile Payment']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CheckoutScreen(paymentMethod: _selectedPaymentMethod),
                ),
              );
            },
            child: const Text('Continue to Checkout'),
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
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
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
          return Center(
            child: Lottie.asset(
              'assets/animations/loading.json',
            ),
          );
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
                final cartProvider = Provider.of<Cart>(context, listen: false);
                try {
                  cartProvider.addItem(product, 1);

                  Fluttertoast.showToast(
                    msg: "Item Added!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0,
                  );
                } catch (error) {
                  if (kDebugMode) {
                    print(error);
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}
