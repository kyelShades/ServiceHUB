import 'dart:developer';

import 'package:flutter/material.dart';
import 'service_list_screen.dart'; // Import the service list screen
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, dynamic>> categories = [
    {'imageIcon': 'assets/icons/cleaning.jpg', 'label': 'Cleaning'}, // https://www.freepik.com/free-vector/cleaner-mopping-floor-with-professional-equipment-flat-icon-white_15080079.htm#fromView=search&page=3&position=36&uuid=cf80819a-39e5-4e8f-8337-f9f63af468d4. Image by macrovector on Freepik
    {'imageIcon': 'assets/icons/lawns.png', 'label': 'Lawns'}, // https://www.freepik.com/free-psd/bush-illustration-design_136947790.htm#fromView=search&page=1&position=14&uuid=6f7cd339-5177-4c9f-bad4-b3f8b074ae8a. Image by freepik
    {'imageIcon': 'assets/icons/repairs.jpg', 'label': 'Repairs'},
    {'imageIcon': 'assets/icons/plumbing.jpg', 'label': 'Plumbing'},
    {'imageIcon': 'assets/icons/electrician_02.jpg', 'label': 'Electricals'},
    {'imageIcon': 'assets/icons/carpenter.jpg', 'label': 'Carpenters'}, //https://www.freepik.com/free-vector/construction-worker-cutting-wood_25669475.htm#fromView=search&page=1&position=2&uuid=1c6e7494-bf4f-47a5-9ad1-4da64fa827f4.Image by brgfx on Freepik
    {'imageIcon': 'assets/icons/painter.jpg', 'label': 'Painting and Decors'}, //https://www.freepik.com/free-vector/back-painter-construction-worker_26213304.htm#fromView=search&page=1&position=25&uuid=5a730208-0d5c-4f0a-bd4e-0a7509f02816. Image by brgfx on Freepik
    {'imageIcon': 'assets/icons/car.png', 'label': 'Car Services'},
    {'imageIcon': 'assets/icons/printing and design.jpg', 'label': 'Printing and designs'},
    {'imageIcon': 'assets/icons/delivery.jpg', 'label': 'Delivery'},
  ];
  var data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("category").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data == null)  {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return  GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio: 1,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var category = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceListScreen(
                            categoryTitle: category['name'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child:  Image.network(
                                category["imageUrl"],
                                width: 80.0,
                                height: 80.0,
                                fit: BoxFit.contain,
                              )

                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          category["name"],
                          style: const TextStyle(
                            fontSize: 11.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              );
            }
        ),



      ),
    );
  }
}
