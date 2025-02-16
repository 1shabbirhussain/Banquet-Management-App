import 'dart:convert';
import 'dart:developer';

import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/utils/snackbar.dart';
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
              .orderBy('created_at',
                  descending: true) // ✅ Match index order (created_at first)
              .orderBy('status',
                  descending: true) // ✅ Match index order (status second)
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
                  final booking =
                      bookings[index].data() as Map<String, dynamic>;
                  return BookingTile(
                    data: booking,
                    onCancel: () =>
                        _cancelBooking(context, booking, bookings[index].id),
                    onRate: booking['status'] == 'Confirmed' &&
                            !booking.containsKey('rating')
                        ? (rating) => _rateBooking(
                            context, booking, bookings[index].id, rating)
                        : null,
                  );
                },
              ),
            );
          },
        ));
  }

  Future<void> _cancelBooking(BuildContext context,
    Map<String, dynamic> booking, String bookingId) async {
  if (booking['status'] == 'Confirmed') {
    SnackbarUtils.showError("You cannot cancel a confirmed booking.");
    return;
  }

  try {
    // ✅ 1. Get the booked date from the booking
    final String bookedDate = booking['date'];
    log("Attempting to remove booked date: $bookedDate from not_available list");

    // ✅ 2. Remove the booked date from banquet's 'not_available' list
    final banquetRef = FirebaseFirestore.instance
        .collection('banquets')
        .doc(booking['banquet_id']);

    await banquetRef.update({
      'not_available': FieldValue.arrayRemove([bookedDate])
    }).then((_) {
      log("Successfully removed booked date: $bookedDate from banquet's not_available list");
    }).catchError((error) {
      log("Failed to remove date from banquet: $error");
    });

    // ✅ 3. Delete the booking record
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .delete()
        .then((_) {
      log("Booking record with ID: $bookingId deleted successfully.");
    }).catchError((error) {
      log("Failed to delete booking record: $error");
    });

    SnackbarUtils.showSuccess("Booking canceled successfully.");
  } catch (e) {
    log("Error during cancellation process: $e");
    SnackbarUtils.showError("Failed to cancel booking: $e");
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

      SnackbarUtils.showSuccess("Thank you for your rating!");
    } catch (e) {
      SnackbarUtils.showError("Failed to submit rating: $e");
    }
  }
}

//========================BOOKING TILE======================================

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
        banquetData = banquetSnapshot.data() as Map<String, dynamic>;
        if (mounted) {
          // ✅ Check if the widget is still in the tree
          setState(() {
            banquetImageUrl = banquetData['images']?.isNotEmpty == true
                ? banquetData['images'][0]
                : null;
          });
        }
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
                  height: status == "Confirmed" && !isPast ? 155 : 205,
                  width: double.infinity,
                  child: Image.memory(
                    base64Decode(banquetImageUrl!),
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
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
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
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
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
                                  arguments: {
                                    "banquet": banquetData,
                                    "hideButton": true
                                  });
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
                if ((status == 'Pending' || status == 'Rejected') && !isPast)
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
                if (isPast && widget.data.containsKey('rating'))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      Text(
                        "Your Ratings: ${widget.data['rating']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                // ===========================Rating============================
              ],
            ),
          ),
          if (status == "Confirmed" &&
              DateTime.parse(date).isAfter(DateTime.now()))
            Positioned(
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.chatScreen, arguments: {
                      'ownerId': widget.data['owner_id'],
                      'bookerId': widget.data['booker_id'],
                      'bookingId': widget.data['booking_id'] ?? "",
                    });
                  },
                  child: const Icon(Icons.chat, color: MyColors.textPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
