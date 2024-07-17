import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_services_screen.dart';
import 'vendor_service_screen.dart';

class ServiceListScreen extends StatefulWidget {
  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  // List to hold fetched services
  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    // Fetch services from Firestore on initialization
    fetchServices();
  }

  // Method to fetch services from Firestore
  Future<void> fetchServices() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('services').get();
      setState(() {
        services = snapshot.docs.map((doc) {
          // Map Firestore document data to the service format
          return {
            'image': Icons.fastfood, // Placeholder, replace with actual image URL if available
            'name': doc['title'],
            'review': doc['review']?.toDouble() ?? 0.0, // Ensure it's a double
            'reviewCount': doc['reviewCount'] ?? 0,
            'dateCreated': doc['dateCreated'] ?? 'N/A',
            'lastUpdate': doc['lastUpdate'] ?? 'N/A',
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];

            return Card(
              elevation: 0.2,
              margin: EdgeInsets.symmetric(vertical: 1.0),
              child: ListTile(
                leading: Icon(service['image'], size: 50.0),
                title: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(service['name'], style: TextStyle(fontSize: 14)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RatingBarIndicator(
                        rating: service['review'],
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                      Text('${service['reviewCount']} Reviews', style: TextStyle(fontSize: 11)),
                      SizedBox(height: 8),
                      Text('Date Created: ${service['dateCreated']}', style: TextStyle(fontSize: 9)),
                      Text('Last Update: ${service['lastUpdate']}', style: TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorServiceScreen(serviceName: service['name']),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddServicesScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ServiceListScreen(),
  ));
}
