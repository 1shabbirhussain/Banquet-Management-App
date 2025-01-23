
import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType inputType;
  final bool isPasswordField;
  final IconData? prefixIcon;
  final Function(String)? onChanged;
  final int? maxLength;
  final String? Function(String?)? validator; // New validator function

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.inputType = TextInputType.text,
    this.isPasswordField = false,
    this.prefixIcon,
    this.onChanged,
    this.maxLength,
    this.validator,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true; // Controls password visibility
  String? _errorText; // For validation messages

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPasswordField ? _obscureText : false,
      keyboardType: widget.inputType,
      maxLength: widget.maxLength,
      validator:widget.validator ,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black26, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black26, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black26, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyColors.red100, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyColors.red100, width: 1.5),
        ),
        hintText: widget.hintText,
        labelText: widget.label,
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        border: InputBorder.none,
        counterText: "",
        errorText: _errorText, // Display validation message
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: Colors.grey, size: 20)
            : null,
        suffixIcon: widget.isPasswordField
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
