import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  //toMap() {}

  Map<String, dynamic> toMap() {
    return {
      'productID': product.id,
      'productName': product.name,
      'sellingPrice': product.sellingPrice,
      'quantity': quantity,
    };
  }
}

class Cart with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount {
    return _items.fold(
        0.0, (sum, item) => sum + item.quantity * item.product.sellingPrice);
  }

  void addItem(Product product, int quantity) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void decrementItem(Product product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity -= 1;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clear() {
    _items = [];
    notifyListeners();
  }
}
