class Product {
  final String id;
  final double sellingPrice;
  final double buyingPrice;
  final String name;
  final int quantity;
  final String uom;

  Product({
    required this.id,
    required this.sellingPrice,
    required this.buyingPrice,
    required this.name,
    required this.quantity,
    required this.uom,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      sellingPrice: data['sellingPrice'],
      buyingPrice: data['buyingPrice'],
      name: data['name'],
      quantity: data['quantity'],
      uom: data['uom'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellingPrice': sellingPrice,
      'buyingPrice': buyingPrice,
      'name': name,
      'quantity': quantity,
      'uom': uom,
    };
  }

  //Recheck if there are any issues

  Map<String, dynamic> toMap() {
    return {
      'productid': id,
      'name': name,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'buyingPrice': buyingPrice,
      'uom': uom,
    };
  }
}
