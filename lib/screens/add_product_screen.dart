import 'package:flutter/material.dart';
import 'package:shop_manager_admin/screens/loading_screen.dart';
import 'package:shop_manager_admin/widgets/custom_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedUom = 'feet';
  bool _isLoading = false;

  final List<String> _uomOptions = [
    'feet',
    'meters',
    'inches',
    'kg',
    'yards',
    'none'
  ];
  
void _updatesubmitForm() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the product already exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: _nameController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Product exists, update it
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        await FirebaseFirestore.instance
            .collection('products')
            .doc(docSnapshot.id)
            .update({
          'sellingPrice': double.parse(_priceController.text),
          'buyingPrice': double.parse(_buyingPriceController.text),
          'quantity': int.parse(_quantityController.text),
        });

        // Update local product object
        final updatedProduct = Product(
          id: docSnapshot.id,
          name: _nameController.text,
          sellingPrice: double.parse(_priceController.text),
          buyingPrice: double.parse(_buyingPriceController.text),
          quantity: int.parse(_quantityController.text),
          uom: _selectedUom,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product ${updatedProduct.name} updated!')),
        );
      } else {
        // Product does not exist, show a toast message
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product doesnot exist add it as a new product')),
        );
      }
    } catch (e) {
      CustomToast(message: e.toString());
    } finally {
      _buyingPriceController.clear();
      _nameController.clear();
      _priceController.clear();
      _quantityController.clear();
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
           QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: _nameController.text)
          .get();
        if(querySnapshot.docs.isEmpty){
        final docRef =
            await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text,
          'sellingPrice': double.parse(_priceController.text),
          'buyingPrice': double.parse(_buyingPriceController.text),
          'quantity': int.parse(_quantityController.text),
          'uom': _selectedUom,
        });

        final newProduct = Product(
          id: docRef.id,
          name: _nameController.text,
          sellingPrice: double.parse(_priceController.text),
          buyingPrice: double.parse(_buyingPriceController.text),
          quantity: int.parse(_quantityController.text),
          uom: _selectedUom,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product ${_nameController.text} added!')),
        );
        // Update the document with the correct ID
       
            } else{
                ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Already existing product, update product instead')));
            }
      } catch (e) {
        CustomToast(message: e.toString());
      } finally {
        _buyingPriceController.clear();
        _nameController.clear();
        _priceController.clear();
        _quantityController.clear();
        //CustomToast(message: 'Product added!');
        setState(() {
          _isLoading = false;
        });
        
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Selling Price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the selling price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _buyingPriceController,
                    decoration: InputDecoration(
                      labelText: 'Buying Price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the buying price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid quantity';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedUom,
                    decoration: InputDecoration(
                      labelText: 'Unit of Measure',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    items: _uomOptions
                        .map((uom) => DropdownMenuItem(
                              value: uom,
                              child: Text(uom),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUom = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a unit of measure';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Add Product',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                      SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _updatesubmitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Update Product',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Center(
                child: LoadingScreen(),
              )
          ],
        ),
      ),
    );
  }
}
