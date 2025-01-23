import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/views/dashboard_view/booker_home.dart';
import 'package:event_ease/views/my_bookings_view/my_bookings_view.dart';
import 'package:event_ease/views/profile_view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart'; // Import the google_nav_bar package


class NavbarPage extends StatefulWidget {
  final String role;
  const NavbarPage({super.key, required this.role });

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _currentPage = 0;

  // Method to handle the navigation bar tap event
  void _handleIndexChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _getPage(_currentPage),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: SizedBox(
            height: 60,
            child: GNav(
              backgroundColor: MyColors.backgroundDark,
              rippleColor: Colors.grey.shade800,
              hoverColor: Colors.grey.shade700,
              haptic: true,
              tabBorderRadius: 15,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 100),
              gap: 8,
              color: Colors.grey,
              activeColor: MyColors.textSecondary,
              iconSize: 20,
              textSize: 20,
              tabBackgroundColor: MyColors.accentDark.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tabMargin: const EdgeInsets.symmetric(horizontal: 5),
              tabs:  const [
                 GButton(
                  icon: FontAwesomeIcons.house,
                  text: 'Home',
                ),
                 GButton(
                  icon: FontAwesomeIcons.calendarCheck,
                  text: 'Bookings',
                ),
                // GButton(
                //   icon: widget.role == "Therapist" ? FontAwesomeIcons.hospitalUser : FontAwesomeIcons.userDoctor,
                //   text: widget.role == "Therapist" ? 'Patients' :'Therapists',
                // ),
                 GButton(
                  icon: FontAwesomeIcons.user,
                  text: 'Profile',
                ),
              ],
              onTabChange: _handleIndexChanged,
            ),
          ),
        ));
  }

  // Method to return the appropriate page based on the selected tab index
  Widget _getPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        // return HomeScreenView(role: widget.role);
        return const BookerHome();
      case 1:
        // return AppointmentListView(role: widget.role,);
        return const MyBookingsScreen();
      case 2:
        // return widget.role == "Therapist" ? const PatientsList() :const TherapistsListView(specialization: 'All');
        return ProfileView(role: widget.role);
      case 3:
        return ProfileView(role: widget.role);
        // return Container();
      default:
        // return HomeScreenView(role: widget.role);
        return Container();
    }
  }
}
