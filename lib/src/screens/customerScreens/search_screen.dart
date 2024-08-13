import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
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
  String? selectedCategory;
  double? minPrice;
  double? maxPrice;
  String? location;
  bool nearMe = false;
  String? selectedRatingOrder;

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

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Services'),
          content: FutureBuilder<List<String>>(
            future: fetchCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching categories'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No categories available'));
              } else {
                List<String> categories = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        dropdownColor: Colors.white,
                      ),
                      SizedBox(height: 16.0),

                      // Price Range
                      Text('Price Range'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Min',
                                labelStyle: TextStyle(color: Colors.black54),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  minPrice = double.tryParse(value);
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Max',
                                labelStyle: TextStyle(color: Colors.black54),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  maxPrice = double.tryParse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),

                      // Location
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            location = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Near Me Checkbox
                      CheckboxListTile(
                        title: Text('Near Me'),
                        value: nearMe,
                        onChanged: (value) {
                          setState(() {
                            nearMe = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.blue,
                      ),
                      SizedBox(height: 16.0),

                      // Rating Order
                      DropdownButtonFormField<String>(
                        value: selectedRatingOrder,
                        items: [
                          DropdownMenuItem(
                            child: Text("Most rated"),
                            value: "desc",
                          ),
                          DropdownMenuItem(
                            child: Text("Less rated"),
                            value: "asc",
                          ),
                        ],
                        onChanged: (newValue) {
                          setState(() {
                            selectedRatingOrder = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Rating Order',
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        dropdownColor: Colors.white,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('category')
          .get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchServices(String query) async {
    if (query.isEmpty) return [];

    try {
      Query queryRef = FirebaseFirestore.instance.collection('services');

      // Apply category filter
      if (selectedCategory != null && selectedCategory!.isNotEmpty) {
        queryRef = queryRef.where('category_name', isEqualTo: selectedCategory);
      }

      // Apply rating order
      if (selectedRatingOrder != null) {
        queryRef = queryRef.orderBy('rating', descending: selectedRatingOrder == "desc");
      }

      QuerySnapshot snapshot = await queryRef.get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['serviceId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching services: $e");
      return [];
    }
  }

  void _applyFilters() {
    setState(() {
      // Trigger a new search with the selected filters
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
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: SearchResultsScreen(
        searchQuery: _searchQuery,
        fetchServices: fetchServices, // Pass the fetchServices method
      ),
    );
  }
}

class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;
  final Future<List<Map<String, dynamic>>> Function(String) fetchServices;

  SearchResultsScreen({
    required this.searchQuery,
    required this.fetchServices,
  });

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

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('favorites')
                    .doc(service['serviceId'])
                    .snapshots(),
                builder: (context, favoriteSnapshot) {
                  bool isFavorite = favoriteSnapshot.data?.exists ?? false;

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
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
                                onPressed: () async {
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    final favoriteRef = FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('favorites')
                                        .doc(service['serviceId']);

                                    if (isFavorite) {
                                      await favoriteRef.delete();
                                    } else {
                                      await favoriteRef.set({
                                        'serviceId': service['serviceId'],
                                        'imageUrl': imageUrl,
                                        'title': title,
                                        'price': price,
                                        'reviewsCount': reviewsCount,
                                        'rating': rating,
                                      });
                                    }
                                  }
                                },
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
                              providerImageUrl: '', // You can add provider details if needed
                              providerName: '', // You can add provider details if needed
                              serviceTitle: title,
                              servicePrice: price.toString(),
                              reviewsCount: reviewsCount,
                              rating: rating,
                              description: service['description'] ?? 'No Description',
                              vendorId: service['vendorId'],
                              serviceId: service['serviceId'],
                              vendorBusinessName: '', // You can add provider details if needed
                              vendorEmail: '', // You can add provider details if needed
                              vendorPhone: '', // You can add provider details if needed
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
