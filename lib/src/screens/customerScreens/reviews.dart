import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewsBottomSheet extends StatefulWidget {
  final String vendorId;
  final String serviceId;

  const ReviewsBottomSheet({required this.vendorId,required this.serviceId, Key? key}) : super(key: key);

  @override
  _ReviewsBottomSheetState createState() => _ReviewsBottomSheetState();
}

class _ReviewsBottomSheetState extends State<ReviewsBottomSheet> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  String _username = 'Anonymous';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(_currentUser!.uid)
            .get();
        setState(() {
          _username = userDoc['username'] as String? ?? 'Anonymous';
        });
      } catch (e) {
        print("Error fetching username: $e");
      }
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchReviews() {
    print("widget.serviceId:${widget.serviceId}");
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('serviceId', isEqualTo: widget.serviceId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
  void _submitReview() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (_reviewController.text.isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and a review')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'serviceId': widget.serviceId,
        'userName': _username,
        'comment': _reviewController.text,
        'rating': _rating,
        'userId': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the vendor document with new rating and review count
      DocumentReference vendorRef = FirebaseFirestore.instance.collection('vendors').doc(widget.vendorId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot vendorSnapshot = await transaction.get(vendorRef);
        if (vendorSnapshot.exists) {
          int newReviewsCount = (vendorSnapshot.get('reviewsCount') ?? 0) + 1;
          double currentRating = (vendorSnapshot.get('rating') ?? 0.0) as double;
          double newRating = ((currentRating * (newReviewsCount - 1)) + _rating) / newReviewsCount;

          transaction.update(vendorRef, {
            'reviewsCount': newReviewsCount,
            'rating': newRating,
          });
        }
      });

      _reviewController.clear();
      setState(() {
        _rating = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review posted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting review: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Reviews', style: TextStyle(fontSize: 16.0)),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _fetchReviews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading reviews'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No reviews available'));
                  }

                  var reviews = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      var review = reviews[index];
                      return ListTile(
                        title: Text(review['userName'] as String),
                        subtitle: Text(review['comment'] as String),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) {
                            return Icon(
                              i < review['rating'] ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 15,
                            );
                          }),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Rating:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_rating == index + 1) {
                          _rating = 0; // Deselect all stars if the current star is tapped again
                        } else {
                          _rating = index + 1; // Otherwise, update the rating to the selected star
                        }
                      });
                    },
                  );
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  labelText: 'Write a review',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  child: Text('Post Review'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
