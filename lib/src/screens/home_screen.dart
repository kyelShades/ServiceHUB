import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servicehub/src/screens/profile.dart';
import 'package:servicehub/src/screens/service_list_screen.dart';
import 'service_details_screen.dart';
import 'package:servicehub/src/widget/bottom_nav.dart';
import 'package:servicehub/src/screens/categories.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    CategoriesScreen(),
    const Text('Favorite Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? _buildAppBar() : null,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 70.0,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8.0),
                    Icon(Icons.search, color: Colors.grey[600]),
                    const SizedBox(width: 8.0),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.grey[600],
                      thickness: 1.0,
                      indent: 8.0,
                      endIndent: 8.0,
                    ),
                    Icon(Icons.filter_list, color: Colors.grey[600]),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            const CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                'https://example.com/path-to-your-image.jpg',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedCategory = '';

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("category").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading categories'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No categories available'),
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: snapshot.data!.docs.map((doc) {
                      var category = doc.data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () => _onCategorySelected(category['name']),
                        child: CategoryButton(
                          label: category['name'],
                          isSelected: _selectedCategory == category['name'],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("services").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading services'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No services available'),
                  );
                }

                var filteredServices = snapshot.data!.docs.where((doc) {
                  var service = doc.data() as Map<String, dynamic>;
                  return _selectedCategory.isEmpty || service['category'] == _selectedCategory;
                }).toList();
                return Column(
                  children: filteredServices.map((doc) {
                    var service = doc.data() as Map<String, dynamic>;
                    log("service:${doc.data()}");
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailsScreen(
                              imageUrl: service['imageUrl'] ?? '',
                              providerImageUrl: service['providerImageUrl'],
                              providerName: service['providerName'] ?? 'Unknown Provider',
                              serviceTitle: service['title'] ?? 'No Title',
                              servicePrice: service['price'] ?? 'No Price',
                              reviewsCount: service['reviewsCount'],
                              rating: service['rating'],
                            ),
                          ),
                        );
                      },
                      child: ServiceCard(
                        imageUrl: service['imageUrl'] ?? '',
                        providerImageUrl: service['providerImageUrl'],
                        providerName: service['providerName'] ?? 'Unknown Provider',
                        serviceTitle: service['title'] ?? 'No Title',
                        servicePrice: service['price'] ?? 'No Price',
                        reviewsCount: service['reviewsCount'],
                        rating: service['rating'], providerId: '',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  CategoryButton({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 11.0,
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String? providerImageUrl;
  final String providerName;
  final String serviceTitle;
  final String servicePrice;
  final int reviewsCount;
  final double rating; // Change to double

  ServiceCard({
    required this.imageUrl,
    required this.providerName,
    required this.serviceTitle,
    required this.servicePrice,
    this.providerImageUrl,
    this.reviewsCount = 0, // Provide default value
    this.rating = 0.0, required String providerId, // Change to double
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Remove any margin around the card
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: const BorderSide(color: Colors.white60, width: 1.0),
      ),
      elevation: 3.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust internal padding as needed
            leading: CircleAvatar(
              backgroundImage: NetworkImage(providerImageUrl ?? 'https://example.com/default-provider.jpg'),
            ),
            title: Text(providerName.isNotEmpty ? providerName : 'Unknown Provider'),
          ),
          Image.network(
            imageUrl.isNotEmpty ? imageUrl : 'https://example.com/default-image.jpg',
            width: double.infinity, // Ensure the image takes the full width
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
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
                      const Spacer(),
                      const Icon(Icons.favorite_border),
                    ],
                  ),
                ),
                Text(serviceTitle.isNotEmpty ? serviceTitle : 'No Title', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                Text(servicePrice.isNotEmpty ? servicePrice : 'No Price', style: const TextStyle(fontSize: 16.0, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
