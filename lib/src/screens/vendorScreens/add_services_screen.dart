import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class AddServicesScreen extends StatefulWidget {
  @override
  _AddServicesScreenState createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends State<AddServicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<DropdownMenuItem<String>> categoryItems = [];
  List<DropdownMenuItem<String>> countryItems = [];
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();

  String? selectedCategory;
  String? selectedCountry;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchCountries();
  }

  Future<void> fetchCategories() async {
    QuerySnapshot snapshot = await _firestore.collection('category').get();
    setState(() {
      categoryItems = snapshot.docs.map((doc) {
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(doc['name']),
        );
      }).toList();
    });
  }

  Future<void> fetchCountries() async {
    QuerySnapshot snapshot = await _firestore.collection('country').get();
    setState(() {
      countryItems = snapshot.docs.map((doc) {
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(doc['name']),
        );
      }).toList();
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadFile(File file) async {
    try {
      String fileName = Path.basename(file.path);
      Reference storageReference = _storage.ref().child('services/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask;
      return await storageReference.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Services', style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Text('Complete this form to add a service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
              SizedBox(height: 20.0),

              // Image upload section
              Text('Upload Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: _image == null
                        ? Text(
                      'No image selected.',
                      style: TextStyle(fontSize: 16),
                    )
                        : Image.file(
                      _image!,
                      height: 100, // Set the height for the image display
                      width: 100,  // Set the width for the image display
                      fit: BoxFit.cover, // Adjust the image to fit within the box
                    ),
                  ),
                  SizedBox(width: 8.0), // Adjust spacing
                  ElevatedButton(
                    onPressed: pickImage, // Call pickImage when button pressed
                    child: Text('Pick Image'),
                  ),
                ],
              ),

              SizedBox(height: 16.0),

              // Text fields for service details
              _buildTextField(titleController, 'Service Title', Icons.title),
              SizedBox(height: 16.0),
              _buildDropdownField('Select Category', categoryItems, (value) {
                setState(() {
                  selectedCategory = value; // Set selected category
                });
              }),
              SizedBox(height: 16.0),
              _buildTextField(descriptionController, 'Describe Service', Icons.description, maxLines: 5),
              SizedBox(height: 16.0),
              _buildTextField(priceController, 'Price', Icons.attach_money, isNumber: true),

              // Contact Information
              SizedBox(height: 30.0),
              Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              _buildTextField(phoneController, 'Phone number', Icons.phone),
              SizedBox(height: 16.0),
              _buildTextField(emailController, 'Email', Icons.email),
              SizedBox(height: 16.0),
              _buildTextField(websiteController, 'Website', Icons.web),

              // Location Information
              SizedBox(height: 30.0),
              Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              _buildTextField(address1Controller, 'Address 1', Icons.location_on),
              SizedBox(height: 16.0),
              _buildTextField(address2Controller, 'Address 2', Icons.location_on),
              SizedBox(height: 16.0),
              _buildDropdownField('Country', countryItems, (value) {
                setState(() {
                  selectedCountry = value; // Set selected country
                });
              }),

              // Button to submit the form
              SizedBox(height: 30.0),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addService, // Call _addService when pressed
                    child: Text('Add Service'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for text fields
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14, color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
      ),
      maxLines: maxLines,
      cursorColor: Colors.blue,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        // Validation logic
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (isNumber && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  // Widget for dropdown fields
  Widget _buildDropdownField(String label, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14, color: Colors.black54),
        prefixIcon: Icon(Icons.category, color: Colors.grey, size: 20),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) {
        // Validation for dropdown selection
        if (value == null) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  // Method to add service details to Firestore
  Future<void> _addService() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Extract data from form fields
      String title = titleController.text;
      String category = selectedCategory ?? '';
      String description = descriptionController.text;
      double price = double.tryParse(priceController.text) ?? 0.0;
      String phone = phoneController.text;
      String email = emailController.text;
      String website = websiteController.text;
      String address1 = address1Controller.text;
      String address2 = address2Controller.text;
      String country = selectedCountry ?? '';

      // Upload the image and get the URL
      String imageUrl = '';
      if (_image != null) {
        try {
          imageUrl = await uploadFile(_image!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload image: $e")),
          );
          return; // Exit if upload fails
        }
      }

      // Get the current vendor ID from FirebaseAuth
      String vendorId = FirebaseAuth.instance.currentUser!.uid;

      // Add service details to Firestore
      await _firestore.collection('services').add({
        'title': title,
        'category': category,
        'description': description,
        'price': price,
        'contact': {
          'phone': phone,
          'email': email,
          'website': website,
        },
        'location': {
          'address1': address1,
          'address2': address2,
          'country': country,
        },
        'image': imageUrl,
        'vendorId': vendorId, // Associate service with current vendor
        'dateCreated': FieldValue.serverTimestamp(),
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      // Clear the form after submission
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Service added successfully")),
      );
    }
  }

  // Method to clear the form fields
  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    phoneController.clear();
    emailController.clear();
    websiteController.clear();
    address1Controller.clear();
    address2Controller.clear();
    setState(() {
      _image = null;
      selectedCategory = null;
      selectedCountry = null;
    });
  }
}
