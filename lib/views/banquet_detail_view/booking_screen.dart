import 'package:event_ease/routes/app_routes.dart';
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
  List<DateTime> unavailableDates = [];

  @override
  void initState() {
    super.initState();
    loadUnavailableDates();
  }

  void loadUnavailableDates() {
    final List<dynamic> dates = widget.banquet['not_available'] ?? [];
    unavailableDates = dates.map((date) => DateTime.parse(date)).toList();
  }

  bool isDateUnavailable(DateTime day) {
    return unavailableDates.contains(DateTime(day.year, day.month, day.day));
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
      body: Padding(
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
            // Calendar
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
                if (!isDateUnavailable(selectedDay)) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                } else {
                  SnackbarUtils.showError("Selected date is unavailable.");
                }
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
              enabledDayPredicate: (day) {
                return !isDateUnavailable(day);
              },
            ),
            const SizedBox(height: 20),

            // Selected Date Display
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
                              Navigator.pop(context, false);
                            },
                            child: const Text("No"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.buttonSecondary,
                            ),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text("Yes", style: TextStyle(color: MyColors.white100)),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    SnackbarUtils.showLoading("Booking your venue...");

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('bookings')
                            .add({
                          'booker_id': user.uid,
                          'banquet_id': widget.banquet['id'],
                          'banquet_name': name,
                          'date': selectedDate!.toIso8601String(),
                          'price': price,
                          'created_at': DateTime.now().toIso8601String(),
                          'status': "Pending",
                        });

                        SnackbarUtils.closeSnackbar();
                        SnackbarUtils.showSuccess("Venue booked susccessfully!");
                        Get.offAllNamed(AppRoutes.navbar, arguments: {'role': 'Venue Booker'});
                      }
                    } catch (e) {
                      SnackbarUtils.closeSnackbar();
                      SnackbarUtils.showError("An error occurred: $e");
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
