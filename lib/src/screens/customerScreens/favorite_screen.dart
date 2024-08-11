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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Favorite Services', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
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
    );
  }
}

class FavoriteServiceCard extends StatelessWidget {
  final Map<String, dynamic> favorite;
  final VoidCallback onRemove;

  FavoriteServiceCard({required this.favorite, required this.onRemove});

  Future<Map<String, dynamic>> _fetchVendorDetails(String vendorId) async {
    try {
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();
      if (!vendorDoc.exists) {
        throw Exception("Vendor not found");
      }
      return vendorDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching vendor data: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchServiceDetails(String serviceId) async {
    try {
      DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .get();
      if (!serviceDoc.exists) {
        throw Exception("Service not found");
      }
      return serviceDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching service data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String serviceId = favorite['serviceId'] ?? '';

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: favorite['imageUrl'] != null
            ? Image.network(favorite['imageUrl'], width: 100, height: 100, fit: BoxFit.cover)
            : Icon(Icons.image, size: 50),
        title: Text(favorite['serviceTitle'] ?? 'No Title', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < (favorite['rating'] ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 15,
                );
              }),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${favorite['reviewsCount'] ?? 0} Reviews'),
                Row(
                  children: [
                    Text('\$${(favorite['servicePrice'] ?? 0).toString()}'),
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
            // Fetch the service and vendor details
            var serviceDetails = await _fetchServiceDetails(serviceId);
            var vendorDetails = await _fetchVendorDetails(serviceDetails['vendorId'] ?? '');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailsScreen(
                  imageUrl: serviceDetails['image'] ?? '',
                  providerImageUrl: vendorDetails['profileImageUrl'] ?? '',
                  providerName: vendorDetails['name'] ?? 'Unknown Provider',
                  serviceTitle: serviceDetails['title'] ?? 'No Title',
                  servicePrice: serviceDetails['price'].toString(),
                  reviewsCount: serviceDetails['reviewsCount'] ?? 0,
                  rating: serviceDetails['rating'] ?? 0.0,
                  description: serviceDetails['description'] ?? 'No Description',
                  vendorId: serviceDetails['vendorId'] ?? '',
                  serviceId: serviceId,
                  vendorBusinessName: vendorDetails['businessName'] ?? 'Unknown Business',
                  vendorEmail: vendorDetails['email'] ?? 'No Email Available',
                  vendorPhone: vendorDetails['phone'] ?? 'No Phone Number Available',
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading service details: $e')),
            );
          }
        },
      ),
    );
  }
}
