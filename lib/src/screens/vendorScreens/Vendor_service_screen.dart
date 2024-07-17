import 'package:flutter/material.dart';

class VendorServiceScreen extends StatelessWidget {
  final String serviceName;

  VendorServiceScreen({required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
      ),
      body: Center(
        child: Text('Details of $serviceName'),
      ),
    );
  }
}
