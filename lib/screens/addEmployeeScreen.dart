import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_manager_admin/models/employee.dart';

class Addemployeescreen extends StatefulWidget {
  const Addemployeescreen({super.key});

  @override
  State<Addemployeescreen> createState() => _AddemployeescreenState();
}

class _AddemployeescreenState extends State<Addemployeescreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String _selectedRoleController = 'None';
  bool _isLoading = false;

  final List<String> _uomOptions = [
    'Editor',
    'User',
    'inactive',
    'None',
  ];

void _updatesubmitForm() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the product already exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('employee')
          .where('email', isEqualTo: _emailController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Product exists, update it
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        await FirebaseFirestore.instance
            .collection('employee')
            .doc(docSnapshot.id)
            .update({
           'email': _emailController.text,
          'phoneNumber': double.parse(_phoneNumberController.text),
          'role': _selectedRoleController
        });

        // Update local product object
      final newProduct = Employee(
          id: docSnapshot.id,
          email: _emailController.text,
          phoneNumber: double.parse(_phoneNumberController.text),
          role: _selectedRoleController,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee ${_emailController} updated!')),
        );
      } else {
        // Product does not exist, show a toast message
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee doesnot exist add it as a new product')),
        );
      }
    } catch (e) {
      CustomToast(message: e.toString());
    } finally {
    _emailController.clear();
        _phoneNumberController.clear();
        _selectedRoleController = "None";
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
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("employee").where("email" ,isEqualTo: _emailController.text).get();
        if(querySnapshot.docs.isEmpty){
        final docRef = await FirebaseFirestore.instance.collection('employees').add({
          'email': _emailController.text,
          'phoneNumber': double.parse(_phoneNumberController.text),
          'role': _selectedRoleController
        });

        final newProduct = Employee(
          id: docRef.id,
          email: _emailController.text,
          phoneNumber: double.parse(_phoneNumberController.text),
          role: _selectedRoleController,
        );
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee with email : ${_emailController.text} is added!')),
        );
        // Update the document with the correct ID
        await FirebaseFirestore.instance
            .collection('employees')
            .doc(docRef.id)
            .set(newProduct.toMap());
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee with ${_emailController.text} is already existing try updating instead!')),
        );
      }
      } 
      
       catch (e) {
        CustomToast(message: e.toString());
      } finally {
        String productname = _emailController.text;
        _emailController.clear();
        _phoneNumberController.clear();
        _selectedRoleController = "None";
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
        title: Text('Add Employee'),
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'User Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    maxLength: 10,
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the phone Number';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedRoleController,
                    decoration: InputDecoration(
                      labelText: 'Role',
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
                        _selectedRoleController = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a role';
                      }
                      if (value.contains("None")) {
                        return "Please select a role";
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
                      'Add Employee',
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
                      'Update Employee',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              )
          ],
        ),
      ),
    );
  }
}


void CustomToast({required String message}) {
  print(message);
}
