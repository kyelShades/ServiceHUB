import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servicehub/src/screens/home_screen.dart';
import 'package:servicehub/src/screens/service_details_screen.dart';

class ServiceListScreen extends StatelessWidget {
  final String categoryTitle;
  final String categoryId;

  ServiceListScreen({required this.categoryTitle, required this.categoryId});

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
      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("services").where("categoryId",isEqualTo: categoryId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null)  {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                   else  if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading services'),
                      );
                    }
                    else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No services available'),
                      );
                    }
                    return  GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 20.0,
                        childAspectRatio: 1,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        
                        var service =  snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        log("service:${service }");
                        return InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailsScreen(
                                  imageUrl: service['imageUrl'],
                                  providerImageUrl: service['providerImageUrl'],
                                  providerName: service['providerName'],
                                  serviceTitle: service['title'],
                                  servicePrice: service['price'],
                                  reviewsCount: service['reviewsCount'],
                                  rating: service['rating'],
                                ),
                              ),
                            );
                          },
                          child: ServiceCard(
                            imageUrl: service['imageUrl'],
                            providerImageUrl: service['providerImageUrl'],
                            providerName: service['providerName'],
                            serviceTitle: service['title'],
                            servicePrice: service['price'],
                            reviewsCount: service['reviewsCount'],
                            rating: service['rating'],
                          ),
                        );
                      },
                    );
                  }
              ),
            ),
          ],
        ),



      ),
    );
  }
}
