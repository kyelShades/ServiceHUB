import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String imageUrl;
  final String providerImageUrl;
  final String providerName;
  final String serviceTitle;
  final String servicePrice;
  final int reviewsCount;
  final double rating;
  final String description;
  final String vendorId;

  ServiceDetailsScreen({
    required this.imageUrl,
    required this.providerImageUrl,
    required this.providerName,
    required this.serviceTitle,
    required this.servicePrice,
    required this.reviewsCount,
    required this.rating,
    required this.description,
    required this.vendorId,
  });

  Future<Map<String, dynamic>> _fetchVendorDetails() async {
    try {
      if (vendorId.isEmpty) {
        throw Exception("Vendor ID is empty");
      }
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();
      if (!vendorDoc.exists) {
        throw Exception("Vendor not found");
      }
      return vendorDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching vendor data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchVendorDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return const Center(child: Text('Error loading vendor details'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Vendor details not available'));
          }

          var vendor = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      Text(
                        serviceTitle,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        servicePrice,
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: Colors.orange,
                              );
                            }),
                          ),
                          const SizedBox(width: 8.0),
                          Text('$reviewsCount Reviews'),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Service Description',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Vendor Information',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(providerImageUrl),
                          ),
                          const SizedBox(width: 8.0),
                          Text(providerName, style: const TextStyle(fontSize: 16.0)),
                        ],
                      ),
                      Text('Business Name: ${vendor['businessName']}'),
                      Text('Email: ${vendor['email']}'),
                      Text('Phone: ${vendor['phone']}'),
                      // Add other vendor details as necessary
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
