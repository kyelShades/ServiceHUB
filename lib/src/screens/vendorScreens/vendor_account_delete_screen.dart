import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'vendor_login.dart';

class VendorAccountDeleteScreen extends StatefulWidget {
  @override
  _VendorAccountDeleteScreenState createState() => _VendorAccountDeleteScreenState();
}

class _VendorAccountDeleteScreenState extends State<VendorAccountDeleteScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _deleteVendorAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user?.uid ?? '';

      if (userId.isNotEmpty) {
        // Step 1: Delete all services associated with the vendor
        QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
            .collection('services')
            .where('vendorId', isEqualTo: userId)
            .get();

        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (QueryDocumentSnapshot serviceDoc in servicesSnapshot.docs) {
          // Step 2: Delete all reviews associated with each service
          QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
              .collection('services')
              .doc(serviceDoc.id)
              .collection('reviews')
              .get();

          for (QueryDocumentSnapshot reviewDoc in reviewsSnapshot.docs) {
            batch.delete(reviewDoc.reference);
          }

          // Delete the service itself
          batch.delete(serviceDoc.reference);
        }

        await batch.commit();

        // Step 3: Delete the vendor profile from Firestore
        await FirebaseFirestore.instance.collection('vendors').doc(userId).delete();

        // Step 4: Delete Firebase Auth account
        await user?.delete();

        // Step 5: Navigate to Vendor Login Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VendorLoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = "Error deleting account: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Account Deletion'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteVendorAccount();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete Account',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              'By deleting your account, all your data including your services will be permanently removed. This action cannot be undone.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 40.0),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmDeleteAccount,
                  child: Text('Delete Account'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: VendorAccountDeleteScreen(),
  ));
}
