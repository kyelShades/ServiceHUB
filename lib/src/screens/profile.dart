import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servicehub/src/screens/vendorScreens/dashboard.dart';
import 'package:servicehub/src/screens/vendorScreens/vendor_login.dart';
import 'package:servicehub/src/screens/vendorScreens/vendor_registration.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    String userId = 'currentUserId'; // Replace with actual user ID logic

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      _usernameController.text = userDoc['username'];
      _emailController.text = userDoc['email'];
      _phoneController.text = userDoc['phone'];
      _addressController.text = userDoc['address'];
      _saveSearchHistory = userDoc['saveSearchHistory'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
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
              onPressed: () => _handleVendorSwitch(context),
              text: 'Switch to Vendor Account',
              foregroundColor: Colors.black54,
            ),
            SizedBox(height: 10.0),
            _buildAccountButton(
              onPressed: () {
                // Handle logout functionality
              },
              text: 'Log Out',
              foregroundColor: Colors.black54,
            ),
            SizedBox(height: 30.0),
            _buildAccountButton(
              onPressed: () {
                // Handle delete account functionality
              },
              text: 'Delete Account',
              backgroundColor: Colors.red,
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
    String userId = 'currentUserId'; // Replace with actual user ID logic
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
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

void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
  ));
}
