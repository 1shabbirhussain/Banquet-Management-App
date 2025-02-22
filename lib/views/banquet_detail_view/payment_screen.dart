import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DummyPaymentScreen extends StatefulWidget {
  final double amount;

  const DummyPaymentScreen({super.key, required this.amount});

  @override
  State<DummyPaymentScreen> createState() => _DummyPaymentScreenState();
}

class _DummyPaymentScreenState extends State<DummyPaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isLoading = false;

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate a payment processing delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });

      // Return true to indicate payment success
      Get.back(result: true); // <-- Add this line
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Payment", style: TextStyle(color: MyColors.textSecondary)),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Image
                Center(
                  child: Image.network(
                    'https://www.pngplay.com/wp-content/uploads/7/Debit-Card-PNG-Images-HD.png', // Add a card image to your assets
                    height: 250,
                  ),
                ),
                const SizedBox(height: 20),
          
                // Card Number Field
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: "Card Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your card number";
                    }
                    if (value.length != 16) {
                      return "Card number must be 16 digits";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
          
                // Expiry Date and CVV Row
                Row(
                  children: [
                    // Expiry Date Field
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: const InputDecoration(
                          labelText: "Expiry Date (MM/YY)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter expiry date";
                          }
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return "Invalid format (MM/YY)";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
          
                    // CVV Field
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: "CVV",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter CVV";
                          }
                          if (value.length != 3) {
                            return "CVV must be 3 digits";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
          
                // Pay Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _processPayment,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        :  Text(
                            "Pay Rs.${widget.amount}",
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}