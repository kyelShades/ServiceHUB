import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servicehub/src/screens/vendorScreens/dashboard.dart';
import 'package:servicehub/src/screens/vendorScreens/vendor_account_delete_screen.dart';
import 'package:servicehub/src/screens/vendorScreens/vendor_login.dart';

class VendorProfileScreen extends StatefulWidget {
  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get the current user ID

      if (userId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _usernameController.text = userDoc.get('name') ?? '';
            _businessNameController.text = userDoc.get('businessName') ?? '';
            _contactController.text = userDoc.get('phone') ?? '';
            _profileImageUrl = userDoc.get('profileImageUrl') ?? '';
            _instagramController.text = userDoc.data().toString().contains('instagram') ? userDoc.get('instagram') : '';
            _facebookController.text = userDoc.data().toString().contains('facebook') ? userDoc.get('facebook') : '';
            _twitterController.text = userDoc.data().toString().contains('twitter') ? userDoc.get('twitter') : '';
            _linkedinController.text = userDoc.data().toString().contains('linkedin') ? userDoc.get('linkedin') : '';
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = "Error loading user details: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserDetails() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('vendors').doc(userId).set({
        'name': _usernameController.text,
        'businessName': _businessNameController.text,
        'phone': _contactController.text,
        'profileImageUrl': _profileImageUrl,
        'instagram': _instagramController.text,
        'facebook': _facebookController.text,
        'twitter': _twitterController.text,
        'linkedin': _linkedinController.text,
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => VendorLoginScreen()),
    );
  }

  void _navigateToDeleteAccount() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => VendorAccountDeleteScreen()));
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
      UploadTask uploadTask = storageReference.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.0),
            // Profile Image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage('assets/placeholder.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            // Account Details
            _buildTextField(_usernameController, 'Username', Icons.person),
            SizedBox(height: 10.0),
            _buildTextField(_businessNameController, 'Business Name', Icons.business),
            SizedBox(height: 10.0),
            _buildTextField(_contactController, 'Contact', Icons.phone),
            SizedBox(height: 50.0),
            // Social Media Handles
            Text('Social Media Handles', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 10.0),
            _buildTextField(_instagramController, 'Instagram', Icons.camera_alt),
            SizedBox(height: 10.0),
            _buildTextField(_facebookController, 'Facebook', Icons.facebook),
            SizedBox(height: 10.0),
            _buildTextField(_twitterController, 'Twitter', Icons.alternate_email),
            SizedBox(height: 10.0),
            _buildTextField(_linkedinController, 'LinkedIn', Icons.business),
            SizedBox(height: 50.0),
            // Your Account
            Text('Your Account', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 10.0),
            _buildAccountButton(
              onPressed: _logout,
              text: 'Logout',
              foregroundColor: Colors.black54,
            ),
            SizedBox(height: 10.0),
            _buildAccountButton(
              onPressed: _navigateToDeleteAccount,
              text: 'Delete Account',
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            SizedBox(height: 30.0),
            _buildAccountButton(
              onPressed: _updateUserDetails,
              text: 'Save Changes',
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black45),
        ),
      ),
    );
  }

  Widget _buildAccountButton({
    required VoidCallback onPressed,
    required String text,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: BeveledRectangleBorder(), // Sharp edges
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: VendorProfileScreen(),
  ));
}
