import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected; // Callback for selected date
  const SchedulePicker({super.key, required this.onDateSelected});

  @override
  SchedulePickerState createState() => SchedulePickerState();
}

class SchedulePickerState extends State<SchedulePicker> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;

    // Adjust initialDate to the next available weekday if it's a weekend
    if (initialDate.weekday == DateTime.saturday) {
      initialDate = initialDate.add(const Duration(days: 2));
    } else if (initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    DateTime lastSelectableDate = now.add(const Duration(days: 7));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: lastSelectableDate,
      selectableDayPredicate: (DateTime day) {
        return day.weekday != DateTime.saturday && day.weekday != DateTime.sunday;
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      // Notify the parent widget
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectDate(context), // Open the date picker on tap
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white, // Customize the background color
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('d MMM, yyyy').format(selectedDate!)
                      : 'Select a date',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MyColors.backgroundDark,
                  ),
                ),
                const Icon(Icons.calendar_today, color: MyColors.backgroundDark),
              ],
            ),
          ),
        ),
      ],
    );
  }
}