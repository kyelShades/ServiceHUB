import 'dart:io'; // for file and directory operations
import 'package:firebase_core/firebase_core.dart'; // firebase core for initialization
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // firebase for database operations
import 'package:firebase_storage/firebase_storage.dart'; // for file storage in firebase storage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // package for picking images form the gallery or camera
import 'package:path/path.dart' as Path; // path manipulation utilities

//run add_service_screen.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  updateFirestoreDocuments();
  runApp(MyApp());
}

// Function to update documents in Firestore
void updateFirestoreDocuments() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('services').get(); // this fetch all documents from 'services' collection
  WriteBatch batch = FirebaseFirestore.instance.batch();

  // Codes loop through each document in the snapshot
  for (var doc in snapshot.docs) {
    String title = doc['title'];
    String category = doc['category'];
    batch.update(doc.reference, {
      'title_lowercase': title.toLowerCase(),
      'category_lowercase': category.toLowerCase(),
    });
  }

  await batch.commit();
  print("Documents updated successfully");
}

// Root widget of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddServicesScreen(),
    );
  }
}

// Widget for adding services to the app
class AddServicesScreen extends StatefulWidget {
  @override
  _AddServicesScreenState createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends State<AddServicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<DropdownMenuItem<String>> categoryItems = []; // dropdown items for categories
  List<DropdownMenuItem<String>> countryItems = []; // dropdown items for countries
  File? _image; // this is a file variable to store the selected image
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>(); // key for form validation

  final TextEditingController titleController = TextEditingController(); // service title controller
  final TextEditingController descriptionController = TextEditingController(); // service description controller
  final TextEditingController priceController = TextEditingController(); // service price controller
  final TextEditingController phoneController = TextEditingController(); // phone number controller
  final TextEditingController emailController = TextEditingController(); // email controller
  final TextEditingController websiteController = TextEditingController(); // controller for website
  final TextEditingController address1Controller = TextEditingController(); // controller for address line 1
  final TextEditingController address2Controller = TextEditingController(); // controller for address line 2

  String? selectedCategory; // variable to store selected category
  String? selectedCategoryName; // variable to store selected category name
  String? selectedCountry; // variable to store selected country
  String? selectedCountryName; // variable to store selected country name

  @override
  void initState() {
    super.initState();
    fetchCategories(); // fetch categories from Firestore
    fetchCountries(); // fetch countries from Firestore
  }

  // Fetching categories from Firestore and populating dropdown
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

  // Fetching countries from Firestore and populating dropdown
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

  // Uploading image using the image picker
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path); // set the selected image file
      } else {
        print('No image selected.'); // log if no image is selected
      }
    });
  }

  // Uploading the selected image file to Firebase Storage and returning the URL
  Future<String> uploadFile(File file) async {
    try {
      String fileName = Path.basename(file.path); // extract the file name from the path
      Reference storageReference = _storage.ref().child('services/$fileName'); // create a reference to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(file); // create an upload task
      await uploadTask;
      return await storageReference.getDownloadURL(); // return the download URL of the uploaded file
    } catch (e) {
      print("Error uploading file: $e");
      throw e;
    }
  }

  // Function to add new service to Firestore
  Future<void> _addService() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = _image != null ? await uploadFile(_image!) : '';

      // Construct the service document data with category and country names included
      Map<String, dynamic> serviceData = {
        'title': titleController.text,
        'category': selectedCategory ?? '',
        'category_name': selectedCategoryName ?? '', // Include category name in the Firestore document
        'description': descriptionController.text,
        'price': double.tryParse(priceController.text) ?? 0,
        'contact': {
          'phone': phoneController.text,
          'email': emailController.text,
          'website': websiteController.text,
        },
        'location': {
          'address1': address1Controller.text,
          'address2': address2Controller.text,
          'country': selectedCountry ?? '',
          'country_name': selectedCountryName ?? '', // Include country name in the Firestore document
        },
        'image': imageUrl,
        'vendorId': FirebaseAuth.instance.currentUser?.uid,
        'dateCreated': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('services').add(serviceData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service added successfully")));
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add service: $e")));
      }
    }
  }

  // Clear the form fields
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
      selectedCategoryName = null;
      selectedCountry = null;
      selectedCountryName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Services'),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePickerSection(),
              SizedBox(height: 20.0),
              _buildTextField(titleController, 'Service Title', Icons.title),
              SizedBox(height: 10.0),
              _buildDropdownField('Select Category', categoryItems, (value) {
                setState(() {
                  selectedCategory = value;
                  selectedCategoryName = categoryItems.firstWhere((item) => item.value == value).child is Text
                      ? (categoryItems.firstWhere((item) => item.value == value).child as Text).data
                      : '';
                });
              }),
              SizedBox(height: 10.0),
              _buildTextField(descriptionController, 'Describe Service', Icons.description, maxLines: 5),
              SizedBox(height: 10.0),
              _buildTextField(priceController, 'Price', Icons.attach_money, isNumber: true),
              SizedBox(height: 10.0),
              _buildContactInfoSection(),
              _buildLocationInfoSection(),
              SizedBox(height: 20.0),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() => Column(
    children: [
      Text('Upload Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      SizedBox(height: 10.0),
      Row(
        children: [
          Expanded(
            child: _image == null
                ? Text('No image selected.', style: TextStyle(fontSize: 16))
                : Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
          ),
          SizedBox(width: 8.0),
          ElevatedButton(onPressed: pickImage, child: Text('Pick Image')),
        ],
      ),
      SizedBox(height: 16.0),
    ],
  );

  Widget _buildContactInfoSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 20.0),
      Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      SizedBox(height: 10.0),
      _buildTextField(phoneController, 'Phone number', Icons.phone),
      SizedBox(height: 10.0),
      _buildTextField(emailController, 'Email', Icons.email),
      SizedBox(height: 10.0),
      _buildTextField(websiteController, 'Website', Icons.web),
      SizedBox(height: 30.0),
    ],
  );

  Widget _buildLocationInfoSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      SizedBox(height: 10.0),
      _buildTextField(address1Controller, 'Address', Icons.location_on),
      SizedBox(height: 10.0),
      _buildTextField(address2Controller, 'Post code', Icons.location_on),
      SizedBox(height: 10.0),
      _buildDropdownField('Country', countryItems, (value) {
        setState(() {
          selectedCountry = value;
          selectedCountryName = countryItems.firstWhere((item) => item.value == value).child is Text
              ? (countryItems.firstWhere((item) => item.value == value).child as Text).data
              : '';
        });
      }),
      SizedBox(height: 16.0),
    ],
  );

  Widget _buildSubmitButton() => Center(
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _addService,
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
  );

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) => TextFormField(
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
      if (value == null || value.isEmpty) {
        return '$label is required';
      }
      if (isNumber && double.tryParse(value) == null) {
        return 'Please enter a valid number';
      }
      return null;
    },
  );

  Widget _buildDropdownField(String label, List<DropdownMenuItem<String>> items, Function(String?) onChanged) => DropdownButtonFormField<String>(
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
      if (value == null) {
        return '$label is required';
      }
      return null;
    },
  );
}
