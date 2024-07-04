import 'package:flutter/material.dart';
import 'package:servicehub/src/screens/profile.dart';
import 'service_details_screen.dart';
import 'package:servicehub/src/widget/bottom_nav.dart';
import 'package:servicehub/src/screens/categories.dart';
import 'package:servicehub/src/screens/profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    CategoriesScreen(), // Ensure CategoriesScreen is added here
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
      backgroundColor: Colors.grey[100],
      appBar: _selectedIndex == 0
          ? _buildAppBar()
          : null,
      body: _widgetOptions.elementAt(_selectedIndex), // Update the body to use _widgetOptions
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 70.0,
      backgroundColor: Colors.white,
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
                'https://example.com/path-to-your-image.jpg', // Replace with your image URL
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryButton(label: 'IT', isSelected: true),
                  const SizedBox(width: 8.0),
                  CategoryButton(label: 'Consulting', isSelected: false),
                  const SizedBox(width: 8.0),
                  CategoryButton(label: 'Home Services', isSelected: false),
                  const SizedBox(width: 8.0),
                  CategoryButton(label: 'Home Services', isSelected: false),
                  const SizedBox(width: 8.0),
                  CategoryButton(label: 'Home Services', isSelected: false),
                  const SizedBox(width: 8.0),
                  CategoryButton(label: 'Home Services', isSelected: false),
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            ServiceCard(
              imageUrl: 'https://example.com/path-to-service-image.jpg',
              providerImageUrl: 'https://example.com/path-to-provider-image.jpg',
              providerName: 'Service Provider',
              serviceTitle: 'Service Title',
              servicePrice: '£0.00',
              reviewsCount: 300,
              rating: 4.5,
            ),
            ServiceCard(
              imageUrl: 'https://example.com/path-to-service-image.jpg',
              providerImageUrl: 'https://example.com/path-to-provider-image.jpg',
              providerName: 'Service Provider',
              serviceTitle: 'Service Title',
              servicePrice: '£0.00',
              reviewsCount: 300,
              rating: 4.5,
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
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 16.0,
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String providerImageUrl;
  final String providerName;
  final String serviceTitle;
  final String servicePrice;
  final int reviewsCount;
  final double rating;

  ServiceCard({
    required this.imageUrl,
    required this.providerImageUrl,
    required this.providerName,
    required this.serviceTitle,
    required this.servicePrice,
    required this.reviewsCount,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: const BorderSide(color: Colors.white60, width: 1.0),
      ),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(providerImageUrl),
              ),
              title: Text(providerName),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to service details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceDetailsScreen(),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/3330179.jpg', // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
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
            Text(serviceTitle, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            Text(servicePrice, style: const TextStyle(fontSize: 16.0, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}