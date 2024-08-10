import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'service_details_screen.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('You need to be logged in to view favorites'));
    }

    return WillPopScope(
      onWillPop: () async {
        // Define the behavior when the back button is pressed
        Navigator.of(context).pushReplacementNamed('/home'); // Replace this with your desired route
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Favorite Services', style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading favorites'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No favorite services'));
            }

            var favoriteServices = snapshot.data!.docs.map((doc) {
              var favorite = doc.data() as Map<String, dynamic>;
              return FavoriteServiceCard(
                favorite: favorite,
                onRemove: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('favorites')
                      .doc(doc.id)
                      .delete();
                },
              );
            }).toList();

            return ListView(
              children: favoriteServices,
            );
          },
        ),
      ),
    );
  }
}

class FavoriteServiceCard extends StatelessWidget {
  final Map<String, dynamic> favorite;
  final VoidCallback onRemove;

  FavoriteServiceCard({required this.favorite, required this.onRemove});

  Future<Map<String, dynamic>> _fetchVendorDetails(String vendorId) async {
    try {
      QuerySnapshot vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .where("id",isEqualTo:vendorId)
          .get();

      print("Fetched ${vendorId}"); // Debugging

      if (vendorDoc.docs.isEmpty) {
        throw Exception("Vendor not found");
      }
      return vendorDoc.docs.first.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching vendor data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = favorite['imageUrl'] ?? '';
    final String title = favorite['serviceTitle'] ?? 'No Title';
    final int reviewsCount = favorite['reviewsCount'] ?? 0;
    final double rating = favorite['rating'] is int
        ? (favorite['rating'] as int).toDouble()
        : favorite['rating'] is String
        ? double.tryParse(favorite['rating']) ?? 0.0
        : favorite['rating'] ?? 0.0;
    final double price = favorite['servicePrice'] is int
        ? (favorite['servicePrice'] as int).toDouble()
        : favorite['servicePrice'] is String
        ? double.tryParse(favorite['servicePrice']) ?? 0.0
        : favorite['servicePrice'] ?? 0.0;
    final String serviceId = favorite['serviceId'] ?? '';

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: imageUrl.isNotEmpty
            ? Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover)
            : Icon(Icons.image, size: 50),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 15,
                );
              }),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$reviewsCount Reviews'),
                Row(
                  children: [
                    Text('\$${price.toString()}'),
                    SizedBox(width: 20), // Add some space between price and remove icon
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          try {
            // Fetch vendor details
            var vendor = await _fetchVendorDetails(favorite['vendorId'] ?? '');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailsScreen(
                  imageUrl: imageUrl,
                  providerImageUrl: favorite['providerImageUrl'] ?? '',
                  providerName: favorite['providerName'] ?? '',
                  serviceTitle: title,
                  servicePrice: price.toString(),
                  reviewsCount: reviewsCount,
                  rating: rating,
                  description: favorite['description'] ?? 'No Description',
                  vendorId: favorite['vendorId'] ?? '',
                  serviceId: serviceId,
                  vendorBusinessName: vendor['businessName'] ?? '',
                  vendorEmail: vendor['email'] ?? '',
                  vendorPhone: vendor['phone'] ?? '',
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching vendor details: $e')),
            );
          }
        },
      ),
    );
  }
}
