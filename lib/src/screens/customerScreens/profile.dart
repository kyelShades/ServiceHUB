import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servicehub/src/screens/vendorScreens/dashboard.dart';
import 'package:servicehub/src/screens/vendorScreens/vendor_login.dart';

import 'account_deletion_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _saveSearchHistory = false;
  bool _isLoading = true;
  String? _error;

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
            .collection('customers')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _usernameController.text = userDoc.get('username') ?? '';
            _emailController.text = userDoc.get('email') ?? '';
            _phoneController.text = userDoc.data().toString().contains('phone') ? userDoc.get('phone') : '';
            _addressController.text = userDoc.data().toString().contains('address') ? userDoc.get('address') : '';
            _saveSearchHistory = userDoc.data().toString().contains('saveSearchHistory')
                ? (userDoc.get('saveSearchHistory') is bool
                ? userDoc.get('saveSearchHistory')
                : userDoc.get('saveSearchHistory').toString().toLowerCase() == 'true')
                : false;
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
      await FirebaseFirestore.instance.collection('customers').doc(userId).set({
        'username': _usernameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'saveSearchHistory': _saveSearchHistory,
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _navigateToDeleteAccount() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccountDeleteScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Profile',
        ),
      ),
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
            // Account Details
            Text('Account Details', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 10.0),
            _buildTextField(_usernameController, 'Username'),
            SizedBox(height: 10.0),
            _buildTextField(_emailController, 'Email'),
            SizedBox(height: 10.0),
            _buildTextField(_phoneController, 'Phone'),
            SizedBox(height: 10.0),
            _buildTextField(_addressController, 'Address'),
            SizedBox(height: 40.0),
            // Preferences
            Text('Preferences', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 10.0),
            // Clear Search History Button
            _buildAccountButton(
              onPressed: () {
                // Add functionality to clear search history
              },
              text: 'Clear Search History',
              foregroundColor: Colors.black54,
            ),
            SizedBox(height: 10.0),
            // Save Search History Toggle
            GestureDetector(
              onTap: () {
                setState(() {
                  _saveSearchHistory = !_saveSearchHistory;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text('Save Search History'),
                  ),
                  Switch(
                    value: _saveSearchHistory,
                    onChanged: (value) {
                      setState(() {
                        _saveSearchHistory = value;
                      });
                    },
                    activeColor: Colors.blue, // Set active color to blue
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.0),
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

  TextField _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
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

  void _handleVendorSwitch(BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get the current user ID

    if (userId.isNotEmpty) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc['isVendor'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VendorLoginScreen()),
        );
      }
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
  ));
}
