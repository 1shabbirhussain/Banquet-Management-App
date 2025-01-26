import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:event_ease/utils/colors.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Owner Dashboard",
          style: TextStyle(color: MyColors.textSecondary),
        ),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                "Welcome, Owner!",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Action Cards Section
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                children: [
                  _buildActionCard(
                    context,
                    title: "Manage Banquets",
                    icon: FontAwesomeIcons.list,
                    color: Colors.deepPurple,
                    onTap: () {
                      // Navigate to Manage Banquets
                      Navigator.pushNamed(context, '/manage-banquets');
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: "Manage Bookings",
                    icon: FontAwesomeIcons.calendarAlt,
                    color: Colors.green,
                    onTap: () {
                      // Navigate to Manage Bookings
                      Navigator.pushNamed(context, '/manage-bookings');
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: "Add Banquet",
                    icon: FontAwesomeIcons.plusCircle,
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to Add Banquet Form
                      Navigator.pushNamed(context, '/add-banquet');
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: "Notifications",
                    icon: FontAwesomeIcons.bell,
                    color: Colors.blue,
                    onTap: () {
                      // Navigate to Notifications
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Latest Bookings Section
              Text(
                "Latest Bookings",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildBookingList(),
            ],
          ),
        ),
      ),
    );
  }

  // Action Card Widget
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Latest Bookings Widget
  Widget _buildBookingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // Example: showing 3 latest bookings
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.withOpacity(0.2),
            child: const Icon(Icons.book, color: Colors.deepPurple),
          ),
          title: const Text(
            "Royal Banquet Hall",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("Booking Date: Jan 28, 2025"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to Booking Details
          },
        );
      },
    );
  }
}
