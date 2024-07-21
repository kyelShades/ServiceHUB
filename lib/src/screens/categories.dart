import 'dart:developer';

import 'package:flutter/material.dart';
import 'service_list_screen.dart'; // Import the service list screen
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  var data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

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
                  String? categoryId = snapshot.data!.docs[index].id;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceListScreen(
                            categoryTitle: category['name'],
                            categoryId: categoryId,
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
