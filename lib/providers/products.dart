import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class Products with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];

  List<Product> get products => _products;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs.map((doc) {
        return Product.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (error) {}
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('products').add(product.toFirestore());
      _products.add(Product(
        id: docRef.id,
        sellingPrice: product.sellingPrice,
        buyingPrice: product.buyingPrice,
        name: product.name,
        quantity: product.quantity,
        uom: product.uom,
      ));
    } catch (error) {
      print(error);
    }
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product product) async {
    await _firestore
        .collection('products')
        .doc(id)
        .update(product.toFirestore());
    int index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Stream<List<Product>> get productsStream {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
