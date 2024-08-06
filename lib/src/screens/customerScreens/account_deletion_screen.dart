import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicehub/src/screens/vendorScreens/vendor_login.dart';

class AccountDeleteScreen extends StatelessWidget {
  Future<void> _deleteAccount(BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      try {
        // Delete user data from Firestore
        await FirebaseFirestore.instance.collection('customers').doc(userId).delete();

        // Delete the user account
        await FirebaseAuth.instance.currentUser?.delete();

        // Navigate to the login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VendorLoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'Deleting your account will remove all your data from our system and cannot be undone.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () => _deleteAccount(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete My Account'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AccountDeleteScreen(),
  ));
}
