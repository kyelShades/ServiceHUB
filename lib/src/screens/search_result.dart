import 'package:flutter/material.dart';

class SearchResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      SizedBox(width: 8.0),
                      Icon(Icons.search, color: Colors.grey[600]),
                      SizedBox(width: 8.0),
                      Expanded(
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
                      SizedBox(width: 8.0),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  'https://example.com/path-to-your-image.jpg', // Replace with your image URL
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 16.0, // Horizontal space between cards
            mainAxisSpacing: 16.0, // Vertical space between cards
            childAspectRatio: 3 / 4, // Aspect ratio of the cards
          ),
          itemCount: 10, // Number of items (replace with dynamic count if needed)
          itemBuilder: (context, index) {
            return ServiceCard(
              imageUrl: 'https://example.com/path-to-service-image.jpg', // Replace with service image URL
              providerImageUrl: 'https://example.com/path-to-provider-image.jpg', // Replace with provider image URL
              providerName: 'Service Provider $index',
              serviceTitle: 'Service Title $index',
              servicePrice: '£${index * 10}.00',
              reviewsCount: 300 + index,
              rating: 4.5,
            );
          },
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
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.white60, width: 1.0),
      ),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                // Handle card tap
              },
              child: Image.asset(
                'assets/images/3330179.jpg',
                fit: BoxFit.cover,
                height: 120, // Set a fixed height for the image
                width: double.infinity, // Make the image take full width
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 9,
                      );
                    }),
                  ),
                  SizedBox(width: 8.0),
                  Text('$reviewsCount Reviews',

                  ),
                ],
              ),
            ),
            Text(serviceTitle),
            Text(servicePrice),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SearchResultScreen(),
  ));
}
