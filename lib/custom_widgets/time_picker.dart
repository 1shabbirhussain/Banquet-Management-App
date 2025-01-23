import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final Function(String) onTimeSelected; // Callback for selected time

  const TimePicker({super.key, required this.onTimeSelected});

  @override
  TimePickerState createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  String? selectedTimeSlot;

  // List of time slots for the dropdown
  final List<String> timeSlots = [
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "07:00 PM - 08:00 PM",
    "08:00 PM - 09:00 PM",
  ];

  // Function to show a simple dropdown (popup)
  Future<void> _showTimeSlotDropdown() async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select a time slot',
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.3, // Limit height
            child: ListView(
              children: timeSlots.map((String value) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, value); // Return the selected value
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: MyColors.backgroundDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    // Update the selected time slot if the user selects one
    if (selected != null) {
      setState(() {
        selectedTimeSlot = selected;
      });

      // Notify the parent widget about the selected time slot
      widget.onTimeSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTimeSlotDropdown, // Trigger the dropdown when tapped
      child: Container(
        width: double.infinity, // Full width of the screen
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
              selectedTimeSlot ?? 'Select a time slot', // Show selected or placeholder text
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MyColors.backgroundDark,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: MyColors.backgroundDark),
          ],
        ),
      ),
    );
  }
}
