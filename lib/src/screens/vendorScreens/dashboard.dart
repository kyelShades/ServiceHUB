import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:flutter/material.dart'; // Import Flutter material package
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for database access
import 'package:servicehub/src/screens/vendorScreens/add_services_screen.dart'; // Import screen for adding services
import 'package:servicehub/src/screens/vendorScreens/service_list.dart'; // Import screen for service list

// Main class for the Dashboard screen
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState(); // Create the state for DashboardScreen
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<String> vendorNameFuture; // Future to hold vendor name
  late Future<List<Map<String, dynamic>>> servicesFuture; // Future to hold services list
  late String userId; // Variable to hold user ID
  int _selectedIndex = 0; // Current index for BottomNavigationBar

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get current user ID
    vendorNameFuture = _fetchVendorName(); // Fetch vendor name
    servicesFuture = _fetchServices(); // Fetch services associated with the vendor
  }

  // Function to fetch vendor name from Firestore
  Future<String> _fetchVendorName() async {
    try {
      // Get vendor document using user ID
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance.collection('vendors').doc(userId).get();
      if (vendorDoc.exists) {
        return vendorDoc['name']; // Return vendor name if document exists
      } else {
        throw Exception("Vendor document does not exist"); // Handle missing document
      }
    } catch (e) {
      throw Exception("Error fetching vendor data: $e"); // Handle error
    }
  }

  // Function to fetch services associated with the vendor
  Future<List<Map<String, dynamic>>> _fetchServices() async {
    try {
      // Query Firestore for services by vendor ID
      QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance.collection('services').where('vendorId', isEqualTo: userId).get();
      return servicesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(); // Return list of services
    } catch (e) {
      throw Exception("Error fetching services: $e"); // Handle error
    }
  }

  // Function to handle item taps in the BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of widgets for each navigation item
    List<Widget> _widgetOptions = <Widget>[
      _buildDashboardContent(), // First item - Dashboard
      ServiceListScreen(),      // Second item - Your Services
      Center(child: Text('Profile Screen')), // Third item - Profile
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // No shadow
        automaticallyImplyLeading: false, // Disable leading button
        title: Text(
          _selectedIndex == 1 ? 'Your Services' : (_selectedIndex == 2 ? 'Profile' : 'Dashboard'), // Update title based on selected index
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex), // Display selected widget
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Highlight current index
        backgroundColor: Colors.blue, // Background color of navigation bar
        selectedItemColor: Colors.white, // Color for selected item
        unselectedItemColor: Colors.white60, // Color for unselected items
        onTap: _onItemTapped, // Set function to handle tap
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), // Icon for Dashboard
            label: 'Dashboard', // Label for Dashboard
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category), // Icon for Your Services
            label: 'Your Services', // Label for Your Services
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Icon for Profile
            label: 'Profile', // Label for Profile
          ),
        ],
      ),
    );
  }

  // Function to build the dashboard content
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(), // Welcome banner
            const SizedBox(height: 25.0),
            _buildCustomerStats(context),
            const SizedBox(height: 16.0),
            _buildServicesList(), // List of services
          ],
        ),
      ),
    );
  }

  // Function to build the welcome banner
  Widget _buildWelcomeBanner() {
    return FutureBuilder<String>(
      future: vendorNameFuture, // Future for vendor name
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error message
        }
        return Container(
          padding: const EdgeInsets.all(16.0), // Padding around banner
          decoration: BoxDecoration(
            color: Colors.blue, // Background color
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black12, // Shadow color
                blurRadius: 8.0, // Blur radius
                offset: Offset(0, 4), // Offset for shadow
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.0, // Radius for profile image
                backgroundImage: NetworkImage('https://example.com/path-to-your-image.jpg'), // Vendor image URL
              ),
              const SizedBox(width: 16.0), // Spacer
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                children: [
                  Text(
                    'Welcome, ${snapshot.data}', // Welcome message
                    style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '10 people added your service to their favorites', // Additional info
                    style: TextStyle(color: Colors.white, fontSize: 11.0),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to build the customer stats section
  Widget _buildCustomerStats(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddServicesScreen()), // Navigate to AddServicesScreen
        );
      },
      child: Container(
        width: double.infinity, // Full width
        padding: const EdgeInsets.all(16.0), // Padding
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Shadow color
              blurRadius: 8.0, // Blur radius
              offset: Offset(0, 4), // Offset for shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
          children: [
            Text(
              '25', // Customer count
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            Text(
              'customers have contacted you this month', // Info text
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the list of services
  Widget _buildServicesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: servicesFuture, // Future for services
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error message
        }
        List<Map<String, dynamic>> services = snapshot.data ?? []; // List of services
        if (services.isEmpty) {
          return Container(
            width: double.infinity, // Full width
            height: 150.0, // Fixed height
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black12, // Shadow color
                  blurRadius: 8.0, // Blur radius
                  offset: Offset(0, 4), // Offset for shadow
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'You don\'t have any services. Add your services', // Message when no services are found
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
                Positioned(
                  bottom: 16.0, // Position at the bottom
                  right: 16.0, // Position to the right
                  child: FloatingActionButton(
                    backgroundColor: Colors.orange, // Button color
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddServicesScreen()), // Navigate to AddServicesScreen
                      );
                    },
                    child: Icon(Icons.add, color: Colors.white, size: 20), // Add icon
                    mini: true, // Mini button
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.all(16.0), // Padding
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black12, // Shadow color
                  blurRadius: 8.0, // Blur radius
                  offset: Offset(0, 4), // Offset for shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
              children: [
                Text(
                  'Your Services', // Section title
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                Divider(), // Divider line
                const SizedBox(height: 16.0), // Spacer
                Table( // Table for displaying services
                  columnWidths: {
                    0: FlexColumnWidth(8), // Width for service name
                    1: FlexColumnWidth(3), // Width for date updated
                  },
                  children: [
                    TableRow(
                      children: [
                        Text('Service Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)), // Header for service name
                        Text('Date Updated', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)), // Header for date updated
                      ],
                    ),
                    ...services.map((service) { // Map through services
                      return TableRow(
                        children: [
                          Text(service['name'] ?? 'Service Name', style: TextStyle(fontSize: 12)), // Service name
                          Text(service['dateUpdated']?.toDate().toString().split(' ')[0] ?? '', style: TextStyle(fontSize: 12)), // Date updated
                        ],
                      );
                    }).toList(), // Convert list to table rows
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
