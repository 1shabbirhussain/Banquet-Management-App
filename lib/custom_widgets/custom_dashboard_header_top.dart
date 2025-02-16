import 'package:event_ease/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class CustomDashboardHeaderTopWidget extends StatelessWidget {
   CustomDashboardHeaderTopWidget({
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
          width: 80,
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.rightFromBracket,
            color: Colors.white,
          ),
          onPressed: () {
            
          },
        )
      ],
    );
  }
}
