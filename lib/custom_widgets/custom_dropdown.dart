import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String hintText;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
         contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduce vertical padding

      ),
      value: selectedValue,
      onChanged: onChanged,
      isDense: true,

      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
