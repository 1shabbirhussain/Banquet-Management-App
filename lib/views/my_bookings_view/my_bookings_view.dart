import 'dart:developer';

import 'package:event_ease/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ??
        ''; // Fetch current user ID from Firebase Auth

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(color: MyColors.textSecondary),
        ),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('booker_id', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text("An error occurred while fetching bookings."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }

          final bookings = snapshot.data!.docs;

          return Skeletonizer(
            enabled: snapshot.connectionState == ConnectionState.waiting,
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index].data() as Map<String, dynamic>;
                return BookingTile(
                  data: booking,
                  onCancel: () =>
                      _cancelBooking(context, booking, bookings[index].id),
                  onRate: booking['status'] == 'Completed' &&
                          !booking.containsKey('rating')
                      ? (rating) => _rateBooking(
                          context, booking, bookings[index].id, rating)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext context,
      Map<String, dynamic> booking, String bookingId) async {
    if (booking['status'] == 'Confirmed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You cannot cancel a confirmed booking."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking canceled successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to cancel booking: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rateBooking(BuildContext context, Map<String, dynamic> booking,
      String bookingId, double rating) async {
    try {
      // Update the booking with the rating
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'rating': rating,
      });

      // Update the banquet's average rating
      final banquetRef = FirebaseFirestore.instance
          .collection('banquets')
          .doc(booking['banquet_id']);
      final banquetDoc = await banquetRef.get();
      if (banquetDoc.exists) {
        final banquetData = banquetDoc.data() as Map<String, dynamic>;
        final double currentRating = banquetData['ratings']['average'] ?? 0.0;
        final int totalReviews = banquetData['ratings']['reviews'] ?? 0;

        final double newAverage =
            ((currentRating * totalReviews) + rating) / (totalReviews + 1);

        await banquetRef.update({
          'ratings.average': newAverage,
          'ratings.reviews': totalReviews + 1,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thank you for your rating!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit rating: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

//========================BOOKING TILE======================================

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:event_ease/utils/colors.dart';

class BookingTile extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onCancel;
  final Function(double)? onRate;

  const BookingTile({
    super.key,
    required this.data,
    required this.onCancel,
    this.onRate,
  });

  @override
  State<BookingTile> createState() => _BookingTileState();
}

class _BookingTileState extends State<BookingTile> {
  String? banquetImageUrl;
  late Map<String, dynamic> banquetData;

  @override
  void initState() {
    super.initState();
    fetchBanquetDetails();
  }

  Future<void> fetchBanquetDetails() async {
    try {
      final banquetId = widget.data['banquet_id'];
      final banquetSnapshot = await FirebaseFirestore.instance
          .collection('banquets')
          .doc(banquetId)
          .get();

      if (banquetSnapshot.exists) {
        // log("Banquet details fetched successfully.");
        banquetData = banquetSnapshot.data() as Map<String, dynamic>;
        setState(() {
          banquetImageUrl = banquetData['images']?.isNotEmpty == true
              ? banquetData['images'][0] // Get the first image URL
              : null;
        });
        // log("$banquetImageUrl IMAGE URL");
      }
    } catch (e) {
      debugPrint("Error fetching banquet details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = widget.data['status'] ?? 'Unknown Status';
    final String date = widget.data['date'] ?? '';
    final String banquetName = widget.data['banquet_name'] ?? 'Unknown';
    final String price = widget.data['price'] ?? 'N/A';
    final bool isPast = DateTime.parse(date).isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          // Background Image with Opacity
          if (banquetImageUrl != null)
            Opacity(
              opacity: 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height:status== "Confirmed" ?150:  200,
                  width: double.infinity,
                  child: Image.network(
                    banquetImageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    banquetName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: MyColors.textPrimary),
                          const SizedBox(width: 5),
                          Text(
                            "Date: ${DateFormat('d MMM, yyyy').format(DateTime.parse(date))}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87,fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money,
                              size: 16, color: MyColors.textPrimary),
                          const SizedBox(width: 5),
                          Text(
                            "Price: Rs. $price",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.info,
                              size: 16, color: MyColors.textPrimary),
                          const SizedBox(width: 5),
                          Text(
                            "Status: $status",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: status == "Confirmed"
                                  ? Colors.green
                                  : status == "Pending"
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.description,
                              size: 16, color: MyColors.textPrimary),
                          TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.banquetDetailScreen,
                                  arguments: {"banquet" : banquetData , "hideButton": true} );
                              log("$banquetImageUrl Details");
                            },
                            child: const Text(
                              "View Details",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: MyColors.buttonSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ========================Cancel Button=========================
                if (status == 'Pending' || status == 'Rejected')
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: widget.onCancel,
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Cancel Booking",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                // ===========================Rating============================
                if (isPast && !widget.data.containsKey('rating'))
                  Row(
                    children: [
                      const Text("Rate now: "),
                      ...List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: index < (widget.data['rating'] ?? 0)
                                ? Colors.amber
                                : Colors.grey,
                          ),
                          onPressed: () => widget.onRate?.call(index + 1.0),
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
