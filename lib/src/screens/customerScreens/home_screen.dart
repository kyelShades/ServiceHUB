import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widget/bottom_nav.dart';
import 'profile.dart';
import 'categories.dart';
import 'search_screen.dart';
import 'favorite_screen.dart'; // Import FavoriteScreen
import 'service_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> _filters = {};
  String _selectedCategoryId = ''; // Track the selected category

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      // Toggle the selected category
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = ''; // Unselect the category
      } else {
        _selectedCategoryId = categoryId; // Select the category
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Define what should happen when the back button is pressed
        if (_selectedIndex == 0) {
          return true; // Allow back navigation if on the main HomeContent screen
        } else {
          setState(() {
            _selectedIndex = 0; // Navigate to the main HomeContent screen instead
          });
          return false; // Prevent default back navigation
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _selectedIndex == 0 ? _buildAppBar() : null,
        body: _selectedIndex == 0
            ? HomeContent(
          filters: _filters,
          selectedCategoryId: _selectedCategoryId,
        )
            : _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 120.0,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        children: [
          Padding(
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
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchPage(searchQuery: value),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            height: 40.0,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("category")
                  .snapshots(),
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
                      String categoryId = doc.id; // Get the category ID
                      return GestureDetector(
                        onTap: () => _onCategorySelected(categoryId),
                        child: CategoryButton(
                          label: category['name'],
                          isSelected: _selectedCategoryId == categoryId,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
    HomeContent(filters: {}, selectedCategoryId: ''),
    CategoriesScreen(),
    FavoriteScreen(), // Add FavoriteScreen to the options
    ProfileScreen(),
  ];
}

class HomeContent extends StatefulWidget {
  final Map<String, dynamic> filters;
  final String selectedCategoryId;

  HomeContent({required this.filters, required this.selectedCategoryId});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("services").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading services'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No services available'));
                }

                var filteredServices = snapshot.data!.docs.where((doc) {
                  var service = doc.data() as Map<String, dynamic>;
                  return (widget.selectedCategoryId.isEmpty || service['category'] == widget.selectedCategoryId) &&
                      (widget.filters['category'] == null || service['category'] == widget.filters['category']) &&
                      (widget.filters['priceRange'] == null ||
                          (service['price'] >= widget.filters['priceRange'].start &&
                              service['price'] <= widget.filters['priceRange'].end)) &&
                      (widget.filters['location'] == null || service['location'] == widget.filters['location']) &&
                      (widget.filters['rating'] == null || service['rating'] >= widget.filters['rating']);
                }).toList();

                return Column(
                  children: filteredServices.map((doc) {
                    var service = doc.data() as Map<String, dynamic>;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('vendors').doc(service['vendorId']).get(),
                      builder: (context, vendorSnapshot) {
                        if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (vendorSnapshot.hasError) {
                          log('Error loading vendor data: ${vendorSnapshot.error}');
                          return const Center(child: Text('Error loading vendor data'));
                        }
                        if (!vendorSnapshot.hasData || !vendorSnapshot.data!.exists) {
                          log('Vendor data not available for vendorId: ${service['vendorId']}');
                          return const Center(child: Text('Vendor data not available'));
                        }

                        var vendorDetails = vendorSnapshot.data!.data() as Map<String, dynamic>;
                        String vendorBusinessName = vendorDetails['businessName'] ?? 'N/A';
                        String vendorEmail = vendorDetails['email'] ?? 'N/A';
                        String vendorPhone = vendorDetails['phone'] ?? 'N/A';
                        String profileImageUrl = vendorDetails['profileImageUrl'] ?? 'https://example.com/default-avatar.png'; // Use default if not available

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailsScreen(
                                  imageUrl: service['image'],
                                  providerImageUrl: profileImageUrl, // Use the vendor's profile image URL
                                  providerName: vendorDetails['name'] ?? "",
                                  serviceTitle: service['title'],
                                  servicePrice: service['price'].toString(),
                                  reviewsCount: service['reviewsCount'] ?? 0,
                                  rating: service['rating'] ?? 0.0,
                                  description: service['description'],
                                  vendorId: service['vendorId'],
                                  serviceId: doc.id,
                                  vendorBusinessName: vendorBusinessName,
                                  vendorEmail: vendorEmail,
                                  vendorPhone: vendorPhone,
                                ),
                              ),
                            );
                          },
                          child: ServiceCard(
                            serviceId: doc.id,
                            imageUrl: service['image'],
                            providerImageUrl: profileImageUrl, // Use the vendor's profile image URL
                            providerName: vendorDetails['name'] ?? "",
                            serviceTitle: service['title'],
                            servicePrice: service['price'].toString(),
                            reviewsCount: service['reviewsCount'] ?? 0,
                            rating: service['rating'] ?? 0.0,
                            vendorId: service['vendorId'],
                            vendorBusinessName: vendorBusinessName,
                            vendorEmail: vendorEmail,
                            vendorPhone: vendorPhone,
                          ),
                        );
                      },
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
        color: isSelected ? Colors.orange : Colors.grey[200],
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

class ServiceCard extends StatefulWidget {
  final String serviceId;
  final String imageUrl;
  final String providerImageUrl;
  final String providerName;
  final String serviceTitle;
  final String servicePrice;
  int reviewsCount;
  double rating;
  final String vendorId;
  final String vendorBusinessName;
  final String vendorEmail;
  final String vendorPhone;

  ServiceCard({
    required this.serviceId,
    required this.imageUrl,
    required this.providerImageUrl,
    required this.providerName,
    required this.serviceTitle,
    required this.servicePrice,
    required this.reviewsCount,
    required this.rating,
    required this.vendorId,
    required this.vendorBusinessName,
    required this.vendorEmail,
    required this.vendorPhone,
  });

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot favoriteDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.serviceId)
          .get();
      setState(() {
        isFavorite = favoriteDoc.exists;
      });
    }
  }

  Future<void> toggleFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference favoriteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.serviceId);

      if (isFavorite) {
        await favoriteRef.delete();
      } else {
        await favoriteRef.set({
          'serviceId': widget.serviceId,
          'imageUrl': widget.imageUrl,
          'providerImageUrl': widget.providerImageUrl,
          'providerName': widget.providerName,
          'serviceTitle': widget.serviceTitle,
          'servicePrice': widget.servicePrice,
          'reviewsCount': widget.reviewsCount,
          'rating': widget.rating,
        });
      }

      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('services').doc(widget.serviceId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading service data'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Service data not available'));
        }

        var serviceData = snapshot.data!.data() as Map<String, dynamic>;
        widget.reviewsCount = serviceData['reviewsCount'] ?? widget.reviewsCount;
        widget.rating = serviceData['rating'] ?? widget.rating;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 15.0), // Add margin around the card
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            side: const BorderSide(color: Colors.white60, width: 1.0),
          ),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(0.0), // Adjust the padding inside the card
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(widget.providerImageUrl),
                  ),
                  title: Text(widget.providerName),
                ),
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add margin to the Row
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                          );
                        }),
                      ),
                      const SizedBox(width: 5.0),
                      Text('${widget.reviewsCount} Reviews'),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: toggleFavorite,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding for text content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.serviceTitle, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      Text(widget.servicePrice, style: const TextStyle(fontSize: 16.0, color: Colors.grey)),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
