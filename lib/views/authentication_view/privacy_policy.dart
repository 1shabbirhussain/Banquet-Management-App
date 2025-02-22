import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: February 10, 2025',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '1. Introduction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome to our app! This Privacy Policy explains how we collect, use, and protect your information when you use our services. By using our app, you agree to the terms outlined in this policy.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '2. Information We Collect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We may collect the following types of information:',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '• Personal Information: Name, email address, phone number.'),
                  Text('• Usage Data: How you interact with the app.'),
                  Text(
                      '• Device Information: Device type, operating system, and IP address.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '3. How We Use Your Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We use your information to:',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Provide and improve our services.'),
                  Text('• Communicate with you about updates and support.'),
                  Text('• Analyze app usage to enhance user experience.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '4. Data Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We take data security seriously and implement measures to protect your information from unauthorized access, alteration, or disclosure.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '5. Changes to This Policy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We may update this Privacy Policy from time to time. Any changes will be posted on this page, and we encourage you to review it periodically.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '6. Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any questions about this Privacy Policy, please contact us at:',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                const whatsappUrl = "https://wa.me/923158426173";
                if (await canLaunchUrl(whatsappUrl as Uri)) {
                  await launchUrl(whatsappUrl as Uri);
                } else {
                  throw 'Could not launch $whatsappUrl';
                }
              },
              child: const Text(
                '+92 315 8426173',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
