import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/views/banquet_detail_view/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_ease/utils/snackbar.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> banquet;
  const BookingScreen({super.key, required this.banquet});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;

  // ✅ Stream to Get Unavailable Dates in Real-Time
  Stream<List<DateTime>> getUnavailableDatesStream() {
    return FirebaseFirestore.instance
        .collection('banquets')
        .doc(widget.banquet['id'])
        .snapshots()
        .map((snapshot) {
      final List<dynamic>? dates = snapshot.data()?['not_available'];
      if (dates != null) {
        // Add today's date as blocked
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        return dates.map((date) => DateTime.parse(date)).toList()
          ..add(todayDate);
      }
      return [];
    });
  }

  // ✅ Add Selected Date to 'not_available' List in Firestore
  Future<void> addDateToNotAvailableList(DateTime date) async {
    try {
      final banquetRef = FirebaseFirestore.instance
          .collection('banquets')
          .doc(widget.banquet['id']);

      await banquetRef.update({
        'not_available': FieldValue.arrayUnion([date.toIso8601String()])
      });

      print("📅 Date added to 'not_available': ${date.toIso8601String()}");
    } catch (e) {
      SnackbarUtils.showError("Failed to update unavailable dates: $e");
    }
  }

  // ✅ Check if a Date is Unavailable
  bool isDateUnavailable(DateTime day, List<DateTime> unavailableDates) {
    return unavailableDates.any((unavailableDate) =>
        unavailableDate.year == day.year &&
        unavailableDate.month == day.month &&
        unavailableDate.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.banquet['name'] ?? 'Unknown';
    final String price = widget.banquet['price_per_day'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Booking",
          style: TextStyle(color: MyColors.textSecondary),
        ),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
      ),
      body: StreamBuilder<List<DateTime>>(
        stream: getUnavailableDatesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DateTime> unavailableDates = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 📅 Calendar with Real-Time Dates
                const Text(
                  "Select a Date:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TableCalendar(
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: selectedDate ?? DateTime.now(),
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isDateUnavailable(selectedDay, unavailableDates)) {
                      setState(() {
                        selectedDate = selectedDay;
                      });
                    } else {
                      SnackbarUtils.showError("Selected date is unavailable.");
                    }
                  },
                  enabledDayPredicate: (day) {
                    return !isDateUnavailable(day, unavailableDates);
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    disabledTextStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // 🗓️ Selected Date Display
                if (selectedDate != null)
                  Text(
                    "Selected Date: ${selectedDate!.toLocal().toIso8601String().split('T')[0]}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  "Price Per Day: Rs.$price",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.transparent,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.buttonSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: selectedDate == null
              ? null
              : () async {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Confirm Booking"),
                        content: Text(
                          "Are you sure you want to book \"$name\" on ${selectedDate!.toLocal().toIso8601String().split('T')[0]} for Rs.$price?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context, false); // User clicked "No"
                            },
                            child: const Text("No"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.buttonSecondary,
                            ),
                            onPressed: () {
                              Navigator.pop(
                                  context, true); // User clicked "Yes"
                            },
                            child: const Text("Yes",
                                style: TextStyle(color: MyColors.white100)),
                          ),
                        ],
                      );
                    },
                  );

                  // If user confirms, navigate to payment screen
                  if (confirmed == true) {
                    final paymentSuccess = await Get.to<bool>(
                      () => DummyPaymentScreen(
                        amount: double.parse(price),
                      ),
                    );

                    // If payment is successful, proceed to save booking
                    if (paymentSuccess == true) {
                      SnackbarUtils.showLoading("Booking your venue...");

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          // ✅ Create a new booking document reference
                          final bookingRef = FirebaseFirestore.instance
                              .collection('bookings')
                              .doc();

                          // ✅ Save booking details
                          await bookingRef.set({
                            'booking_id': bookingRef.id,
                            'booker_id': user.uid,
                            'banquet_id': widget.banquet['id'],
                            'banquet_name': name,
                            'date': selectedDate!.toIso8601String(),
                            'price': price,
                            'created_at': DateTime.now().toIso8601String(),
                            'status': "Pending",
                            'owner_id': widget.banquet['owner_id'],
                            'image_url': widget.banquet['images'][0],
                          });

                          // ✅ Add selected date to 'not_available' list
                          await addDateToNotAvailableList(selectedDate!);

                          SnackbarUtils.closeSnackbar();
                          SnackbarUtils.showSuccess(
                              "Venue booked successfully!");
                          Get.offAllNamed(AppRoutes.navbar,
                              arguments: {'role': 'Venue Booker'});
                        }
                      } catch (e) {
                        SnackbarUtils.closeSnackbar();
                        SnackbarUtils.showError("An error occurred: $e");
                      }
                    }
                  }
                },
          child: const Text(
            "Confirm Booking",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
