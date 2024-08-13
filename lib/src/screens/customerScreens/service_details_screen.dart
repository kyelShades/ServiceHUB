import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:servicehub/src/screens/customerScreens/reviews.dart'; // Adjust the import according to your file structure

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
  final String serviceId;
  final String vendorBusinessName;
  final String vendorEmail;
  final String vendorPhone;

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
    required this.serviceId,
    required this.vendorBusinessName,
    required this.vendorEmail,
    required this.vendorPhone,
  });

  Future<Map<String, dynamic>> _fetchServiceDetails() async {
    try {
      if (serviceId.isEmpty) {
        throw Exception("Service ID is empty");
      }
      DocumentSnapshot serviceDoc = await FirebaseFirestore.instance.collection('services').doc(serviceId).get();
      if (!serviceDoc.exists) {
        throw Exception("Service not found");
      }
      return serviceDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching service data: $e");
    }
  }

  void _showReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReviewsBottomSheet(vendorId: vendorId);
      },
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(emailUri);
  }

  void _openMap(String address1, String address2) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$address1,$address2';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void _openWebsite(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
        future: _fetchServiceDetails(),
        builder: (context, serviceSnapshot) {
          if (serviceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (serviceSnapshot.hasError) {
            print("Error: ${serviceSnapshot.error}");
            return const Center(child: Text('Error loading service details'));
          }
          if (!serviceSnapshot.hasData) {
            return const Center(child: Text('Service details not available'));
          }

          var service = serviceSnapshot.data!;

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
                        '\$' + servicePrice, // Corrected concatenation
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
                          const SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: () => _showReviews(context),
                            child: const Text('See reviews'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            ),
                          ),
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
                      const SizedBox(height: 25.0),
                      const Text(
                        'Service Information',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text('Contact: ${service['contact']['phone']}'),
                      Text('Email: ${service['contact']['email']}'),
                      Text('Location: ${service['location']['address1']}'),
                      Text('Website: ${service['contact']['website']}'),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Vendor Details',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text('Business Name: $vendorBusinessName'),
                      Text('Vendor Email: $vendorEmail'),
                      Text('Vendor Phone: $vendorPhone'),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.call, color: Colors.green),
                                onPressed: () {
                                  _makePhoneCall(service['contact']['phone']);
                                },
                              ),
                              Text('Call'),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.email, color: Colors.blue),
                                onPressed: () {
                                  _sendEmail(service['contact']['email']);
                                },
                              ),
                              Text('Email'),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.map, color: Colors.red),
                                onPressed: () {
                                  _openMap(service['location']['address1'], service['location']['address2']);
                                },
                              ),
                              Text('Map'),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.web, color: Colors.orange),
                                onPressed: () {
                                  _openWebsite(service['contact']['website']);
                                },
                              ),
                              Text('Website'),
                            ],
                          ),
                        ],
                      ),
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
