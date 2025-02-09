import 'dart:convert';

import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/utils/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  String selectedFilter = "All"; // Default filter
  final List<String> filters = ["All", "Pending", "Confirmed", "Rejected", "Past"];
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Bookings",
          style: TextStyle(color: MyColors.textSecondary),
        ),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').where('owner_id', isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("An error occurred while fetching bookings."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }

          final bookings = snapshot.data!.docs.where((doc) => _filterBookings(doc.data() as Map<String, dynamic>)).toList();

          return bookings.isEmpty
              ? const Center(child: Text("No bookings match your filter."))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index].data() as Map<String, dynamic>;
                    return OwnerBookingTile(
                      data: booking,
                      onConfirm: () => _confirmBooking(context, booking, bookings[index].id),
                      onReject: () => _rejectBooking(context, booking, bookings[index].id),
                    );
                  },
                );
        },
      ),
    );
  }

  bool _filterBookings(Map<String, dynamic> booking) {
    final String status = booking['status'] ?? '';
    final String date = booking['date'] ?? '';
    final DateTime bookingDate = DateTime.parse(date);
    final DateTime today = DateTime.now();

    switch (selectedFilter) {
      case "Pending":
        return status == "Pending";
      case "Confirmed":
        return status == "Confirmed" && !bookingDate.isBefore(today);
      case "Rejected":
        return status == "Rejected";
      case "Past":
        return status == "Confirmed" && bookingDate.isBefore(today);
      default: // "All"
        return true;
    }
  }

  Future<void> _confirmBooking(BuildContext context, Map<String, dynamic> booking, String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'status': 'Confirmed'});

      // Update the banquet's unavailable dates
      final banquetRef = FirebaseFirestore.instance.collection('banquets').doc(booking['banquet_id']);
      final banquetDoc = await banquetRef.get();
      if (banquetDoc.exists) {
        final banquetData = banquetDoc.data() as Map<String, dynamic>;
        final unavailableDates = List<String>.from(banquetData['not_available'] ?? []);
        unavailableDates.add(booking['date']);
        await banquetRef.update({'not_available': unavailableDates});
      }

      SnackbarUtils.showSuccess("Booking confirmed successfully.");
    } catch (e) {
      SnackbarUtils.showError("Failed to confirm booking: $e");
    }
  }

  Future<void> _rejectBooking(BuildContext context, Map<String, dynamic> booking, String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'status': 'Rejected'});

      SnackbarUtils.showSuccess("Booking rejected successfully.");
    } catch (e) {
      SnackbarUtils.showError("Failed to reject booking: $e");
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filter Bookings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: filters
                .map((filter) => RadioListTile<String>(
                      title: Text(filter),
                      value: filter,
                      groupValue: selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

// ========================= OWNER BOOKING TILE ========================= //

class OwnerBookingTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;

  const OwnerBookingTile({
    super.key,
    required this.data,
    this.onConfirm,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final String status = data['status'] ?? 'Unknown Status';
    final String date = data['date'] ?? '';
    final String banquetName = data['banquet_name'] ?? 'Unknown';
    final String price = data['price'] ?? 'N/A';
    final String image = data['image_url'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: status == "Confirmed" || status == "Rejected" ? 150 : 200,
                width: double.infinity,
                child: Image.memory(
                        base64Decode(image),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
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
                    const Icon(Icons.calendar_today, size: 16, color: MyColors.textPrimary),
                    const SizedBox(width: 5),
                    Text(
                      "Date: ${DateFormat('d MMM, yyyy').format(DateTime.parse(date))}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: MyColors.textPrimary),
                    const SizedBox(width: 5),
                    Text(
                      "Price: Rs. $price",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, size: 16, color: MyColors.textPrimary),
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
                    if (status == "Confirmed" && DateTime.parse(date).isAfter(DateTime.now()))
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.chatScreen, arguments: {
                            'ownerId': data['owner_id'],
                            'bookerId': data['booker_id'],
                            'bookingId': data['booking_id'] ?? "",
                          });
                        },
                        child: const Icon(Icons.chat, color: MyColors.textPrimary),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (status == "Pending") ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onReject,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text("Reject", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
