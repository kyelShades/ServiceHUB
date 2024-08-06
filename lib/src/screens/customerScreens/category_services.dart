import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicehub/src/screens/customerScreens/service_details_screen.dart';

class CategoryServiceScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryId;

  CategoryServiceScreen({required this.categoryTitle, required this.categoryId});

  @override
  _CategoryServiceScreenState createState() => _CategoryServiceScreenState();
}

class _CategoryServiceScreenState extends State<CategoryServiceScreen> {
  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('category', isEqualTo: widget.categoryId)
          .get();
      setState(() {
        services = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  Future<Map<String, dynamic>> fetchVendorDetails(String vendorId) async {
    try {
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();
      if (vendorDoc.exists) {
        return vendorDoc.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print("Error fetching vendor details: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.categoryTitle),
      ),
      body: services.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];

          final String imageUrl = service['image'] ?? '';
          final String title = service['title'] ?? 'No Title';
          final int reviewsCount = service['reviewsCount'] ?? 0;
          final double rating = service['rating']?.toDouble() ?? 0.0;
          final double price = service['price']?.toDouble() ?? 0.0;

          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              )
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$reviewsCount Reviews'),
                      Row(
                        children: [
                          Text('\$${price.toString()}'),
                          SizedBox(width: 20), // Add some space between price and favorite icon
                          Icon(Icons.favorite_border),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () async {
                // Fetch vendor details
                var vendorDetails = await fetchVendorDetails(service['vendorId']);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceDetailsScreen(
                      imageUrl: imageUrl,
                      providerImageUrl: service['providerImageUrl'] ?? '',
                      providerName: service['providerName'] ?? '',
                      serviceTitle: title,
                      servicePrice: price.toString(),
                      reviewsCount: reviewsCount,
                      rating: rating,
                      description: service['description'] ?? 'No Description',
                      vendorId: service['vendorId'],
                      serviceId: service['id'],
                      vendorBusinessName: vendorDetails['businessName'] ?? '',
                      vendorEmail: vendorDetails['email'] ?? '',
                      vendorPhone: vendorDetails['phone'] ?? '',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
