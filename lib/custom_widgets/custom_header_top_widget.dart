import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/services/firebase_services.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class CustomHeaderTopWidget extends StatelessWidget {
   CustomHeaderTopWidget({
    super.key,
  });
  final FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Image(
          image: AssetImage('assets/images/logo.png'),
          width: 100,
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.rightFromBracket,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await firebaseService.signOut();
                          if (context.mounted) {
                          Navigator.of(context).pop(); 
                          SnackbarUtils.showSuccess("Logged out successfully");
                          Navigator.of(context).pushReplacementNamed(AppRoutes.ownerLogin); 
                          }
                        } catch (e) {
                          SnackbarUtils.showError("Error logging out: $e");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.buttonSecondary,
                      ),
                      child: const Text("Yes",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          },
        )
      ],
    );
  }
}
