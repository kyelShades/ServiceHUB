import 'package:flutter/material.dart';

class ServiceListScreen extends StatelessWidget {
  final String categoryTitle;

  ServiceListScreen({required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () {
            Navigator.pop(context); // Navigate back to previous screen
          },
        ),
        title: Text(
          categoryTitle,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Center(
        child: Text(
          'Services for $categoryTitle',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
