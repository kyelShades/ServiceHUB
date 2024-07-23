import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_details_screen.dart';

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
        services = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
      ),
      body: services.isEmpty
          ? Center(child: Text('No services available'))
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
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
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
              onTap: () {
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
