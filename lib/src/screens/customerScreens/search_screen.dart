import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_details_screen.dart';

class SearchPage extends StatefulWidget {
  final String searchQuery;

  SearchPage({required this.searchQuery});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchQuery;
    _searchController.text = _searchQuery;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            filled: true,
            fillColor: Colors.grey[150],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
          ),
        ),
      ),
      body: SearchResultsScreen(searchQuery: _searchQuery),
    );
  }
}

class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;

  SearchResultsScreen({required this.searchQuery});

  Future<List<Map<String, dynamic>>> fetchServices(String query) async {
    if (query.isEmpty) return [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['serviceId'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching services: $e");
      return [];
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchServices(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching services'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No services available'));
        } else {
          final services = snapshot.data!;
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];

              final String imageUrl = service['image'] ?? '';
              final String title = service['title'] ?? 'No Title';
              final int reviewsCount = service['reviewsCount'] ?? 0;
              final double rating = service['rating']?.toDouble() ?? 0.0;
              final double price = service['price']?.toDouble() ?? 0.0;

              return FutureBuilder<Map<String, dynamic>>(
                future: fetchVendorDetails(service['vendorId']),
                builder: (context, vendorSnapshot) {
                  if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (vendorSnapshot.hasError || !vendorSnapshot.hasData) {
                    return ListTile(
                      title: Text('Error loading vendor details'),
                    );
                  }

                  var vendorDetails = vendorSnapshot.data!;
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
                          Text('$reviewsCount Reviews'),
                          SizedBox(height: 4), // Add some space before the price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$${price.toString()}'),
                              Icon(Icons.favorite_border),
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
                              providerImageUrl: vendorDetails['profileImageUrl'] ?? '',
                              providerName: vendorDetails['name'] ?? '',
                              serviceTitle: title,
                              servicePrice: price.toString(),
                              reviewsCount: reviewsCount,
                              rating: rating,
                              description: service['description'] ?? 'No Description',
                              vendorId: service['vendorId'],
                              serviceId: service['serviceId'],
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
              );
            },
          );
        }
      },
    );
  }
}
