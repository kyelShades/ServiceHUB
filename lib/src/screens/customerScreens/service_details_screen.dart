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

  Future<Map<String, dynamic>> _fetchVendorDetails() async {
    try {
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();
      if (!vendorDoc.exists) {
        throw Exception("Vendor not found");
      }
      return vendorDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching vendor data: $e");
    }
  }

  void _showReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReviewsBottomSheet(serviceId: serviceId,vendorId: vendorId,);
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

  void _openSocialMedia(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _constructSocialMediaUrl(String platform, String username) {
    switch (platform) {
      case 'instagram':
        return 'https://www.instagram.com/$username';
      case 'facebook':
        return 'https://www.facebook.com/$username';
      case 'twitter':
        return 'https://twitter.com/$username';
      case 'linkedin':
        return 'https://www.linkedin.com/in/$username';
      default:
        return '';
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
        builder: (context, vendorSnapshot) {
          if (vendorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vendorSnapshot.hasError) {
            print("Error: ${vendorSnapshot.error}");
            return const Center(child: Text('Error loading vendor details'));
          }
          if (!vendorSnapshot.hasData) {
            return const Center(child: Text('Vendor details not available'));
          }

          var vendorDetails = vendorSnapshot.data!;

          // Social media usernames
          String? instagramUsername = vendorDetails['instagram'];
          String? facebookUsername = vendorDetails['facebook'];
          String? twitterUsername = vendorDetails['twitter'];
          String? linkedinUsername = vendorDetails['linkedin'];

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
                      if ((instagramUsername != null && instagramUsername.isNotEmpty) ||
                          (facebookUsername != null && facebookUsername.isNotEmpty) ||
                          (twitterUsername != null && twitterUsername.isNotEmpty) ||
                          (linkedinUsername != null && linkedinUsername.isNotEmpty))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Follow Us',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                if (instagramUsername != null && instagramUsername.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.camera_alt, color: Colors.pink),
                                    onPressed: () {
                                      _openSocialMedia(_constructSocialMediaUrl('instagram', instagramUsername));
                                    },
                                  ),
                                if (facebookUsername != null && facebookUsername.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.facebook, color: Colors.blue),
                                    onPressed: () {
                                      _openSocialMedia(_constructSocialMediaUrl('facebook', facebookUsername));
                                    },
                                  ),
                                if (twitterUsername != null && twitterUsername.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.alternate_email, color: Colors.blueAccent),
                                    onPressed: () {
                                      _openSocialMedia(_constructSocialMediaUrl('twitter', twitterUsername));
                                    },
                                  ),
                                if (linkedinUsername != null && linkedinUsername.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.business, color: Colors.blueGrey),
                                    onPressed: () {
                                      _openSocialMedia(_constructSocialMediaUrl('linkedin', linkedinUsername));
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 25.0),
                          ],
                        ),
                      const Text(
                        'Service Information',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text('Contact: ${vendorDetails['phone']}'),
                      Text('Email: ${vendorDetails['email']}'),
                      Text('Business Name: $vendorBusinessName'),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.call, color: Colors.green),
                                onPressed: () {
                                  _makePhoneCall(vendorDetails['phone']);
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
                                  _sendEmail(vendorDetails['email']);
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
                                  _openMap(vendorDetails['address1'] ?? '', vendorDetails['address2'] ?? '');
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
                                  _openWebsite(vendorDetails['website'] ?? '');
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
