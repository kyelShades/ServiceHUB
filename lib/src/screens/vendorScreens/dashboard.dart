import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_services_screen.dart';
import 'service_list.dart';
import 'vendor_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String userId;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      _buildDashboardContent(),
      ServiceListScreen(),
      VendorProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Prevent the system back button from navigating back to the login screen
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            _selectedIndex == 1 ? 'Your Services' : (_selectedIndex == 2 ? 'Profile' : 'Dashboard'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[150],
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Your Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 25.0),
            _buildCustomerStats(context),
            const SizedBox(height: 16.0),
            _buildServicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('vendors').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('Vendor data not available');
        }
        final vendorData = snapshot.data!.data() as Map<String, dynamic>;
        final profileImageUrl = vendorData['profileImageUrl'] ?? 'https://example.com/path-to-your-image.jpg';

        // Extract the first name from the full name
        final fullName = vendorData['name'] ?? '';
        final firstName = fullName.split(' ')[0]; // Take the first part of the name

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $firstName',
                    style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerStats(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddServicesScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '25',
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            Text(
              'customers have contacted you this month',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('services').where('vendorId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            height: 150.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'You don\'t have any services. Add your services',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    backgroundColor: Colors.orange,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddServicesScreen()),
                      );
                    },
                    child: Icon(Icons.add, color: Colors.white, size: 20),
                    mini: true,
                  ),
                ),
              ],
            ),
          );
        } else {
          List<Map<String, dynamic>> services = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Services',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                Divider(),
                const SizedBox(height: 12.0),
                Table(
                  columnWidths: {
                    0: FlexColumnWidth(8),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    ...services.map((service) {
                      return TableRow(
                        children: [
                          Text(service['title'] ?? 'Service Name', style: TextStyle(fontSize: 16)),
                          Text(service['dateCreated']?.toDate().toString().split(' ')[0] ?? '', style: TextStyle(fontSize: 16)),
                        ],
                      );
                    }).toList(),
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
