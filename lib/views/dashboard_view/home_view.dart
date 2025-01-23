// import 'dart:convert';
// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:vr_healer/custom_widgets/custom_header_top_widget.dart';
// import 'package:vr_healer/custom_widgets/custom_listtile_widget.dart';
// import 'package:vr_healer/routes/app_routes.dart';
// import 'package:vr_healer/services/firebase_services.dart';
// import 'package:vr_healer/utils/colors.dart';

// class HomeScreenView extends StatefulWidget {
//   final String role;
//   const HomeScreenView({super.key, this.role = 'Patient'});

//   @override
//   State<HomeScreenView> createState() => _HomeScreenViewState();
// }

// class _HomeScreenViewState extends State<HomeScreenView> {
//   FirebaseService firebaseService = FirebaseService();
//   final Stream<QuerySnapshot> _therapistsStream =
//       FirebaseFirestore.instance.collection('therapists').snapshots();
//   // --------------------------------------- slected category Start ------------------
//   String selectedCategory = '';
//   List<String> categories = ['Claustrophobia', 'Nyctophobia', 'Hydrophobia'];
//   String userName = '';
//   String profilePictureUrl = '';
//   String gender = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchUserName();
//   }

//   void fetchUserName() async {
//     try {
//       final User? currentUser = firebaseService.getCurrentUser();
//       if (currentUser != null) {
//         DocumentSnapshot userDoc = widget.role == 'Patient'
//             ? await FirebaseFirestore.instance
//                 .collection('patients')
//                 .doc(currentUser.uid)
//                 .get()
//             : await FirebaseFirestore.instance
//                 .collection('therapists')
//                 .doc(currentUser.uid)
//                 .get();
//         if (userDoc.exists) {
//           setState(() {
//             userName = userDoc['name'] ?? 'Guest';
//             gender = userDoc['gender'] ?? 'Male';
//             profilePictureUrl = (userDoc.data() as Map<String, dynamic>)
//                     .containsKey('profile_picture_base64')
//                 ? userDoc['profile_picture_base64']
//                 : '';
//           });
//         } else {
//           log('No user data found for the current user.');
//         }
//       } else {
//         log('No user is logged in.');
//       }
//     } catch (e) {
//       log('Error fetching user name: $e');
//     }
//   }

//   void selectCategory(String category) {
//     setState(() {
//       selectedCategory = category;
//     });
//   }

//   int selectedCardIndex = -1;
//   // --------------------------------------- slected category end ------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         extendBodyBehindAppBar: false,
//         extendBody: false,
//         body: Column(
//           children: [
//             customHeaderWidget(context),
//             if (widget.role == 'Patient') ...[
//               customTherapistsCardWidget(context),
//               customTherapistTileWidget(),
//             ],
//             if (widget.role == 'Therapist') ...[
//               Expanded(child: customAppointmentsListWidget()),
//             ]
//           ],
//         ));
//   }

// //==============================================================================
// // --------------------------------------- CUSTOM WIDGETS ----------------------
// //==============================================================================

//   Container customHeaderWidget(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//       height: MediaQuery.of(context).size.height * 0.45,
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             MyColors.backgroundDark,
//             MyColors.backgroundDark,
//             MyColors.backgroundLight,
//           ],
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           CustomHeaderTopWidget(),
//           Center(
//             child: CircleAvatar(
//               radius: 50,
//               backgroundImage: profilePictureUrl.isNotEmpty &&
//                       profilePictureUrl != ""
//                   ? MemoryImage(base64Decode(profilePictureUrl))
//                   : gender == "Male"
//                       ? const NetworkImage(
//                               "https://www.shareicon.net/data/128x128/2016/09/15/829459_man_512x512.png")
//                           as ImageProvider
//                       : const NetworkImage(
//                               "https://avatar.iran.liara.run/public/93")
//                           as ImageProvider,
//               backgroundColor: Colors.white,
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Welcome Back! ",
//                       style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: MyColors.white100),
//                     ),
//                     Text(
//                       userName,
//                       style: GoogleFonts.poppins(
//                           fontSize: 25,
//                           fontWeight: FontWeight.w500,
//                           color: MyColors.textSecondary),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Center(
//             child: Text.rich(
//               textAlign: TextAlign.center,
//               TextSpan(
//                 children: [
//                   TextSpan(
//                     text: widget.role == "Patient"
//                         ? "Let's Find "
//                         : "Let's Support ",
//                     style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: MyColors.white100),
//                   ),
//                   TextSpan(
//                     text: "Your ",
//                     style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: MyColors.white100),
//                   ),
//                   TextSpan(
//                     text: widget.role == "Patient" ? "Therapist" : "Patients",
//                     style: GoogleFonts.poppins(
//                         fontSize: 25,
//                         fontWeight: FontWeight.w600,
//                         color: MyColors.textSecondary),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Container customTherapistsCardWidget(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16,20,16,10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Text(
//             "Therapists for Specific Phobias",
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: MyColors.textPrimary,
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//             SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//               buildCategoryCard(
//                 context, 'assets/claustro.jpeg', "Claustrophobia", "Claustrophobia"),
//                 const SizedBox(width: 10),
//               buildCategoryCard(
//                 context, "assets/nycto.jpeg", "Nyctophobia", "Nyctophobia"),
//                 const SizedBox(width: 10),
//               buildCategoryCard(
//                 context, 'assets/hydro.jpeg', "Hydrophobia", "Hydrophobia"),
//                 const SizedBox(width: 10),
//               buildCategoryCard(context, 'assets/seeAll.jpg', "See All", "All"),
//               ],
//             ),
//             )
//         ],
//       ),
//     );
//   }

//   Widget buildCategoryCard(
//       BuildContext context, String image, String label, String category) {
//     return Container(
//       padding: const EdgeInsets.symmetric( vertical: 2),
//       width: 100,
//       child: Material(
//         elevation: 5,
//         borderRadius: BorderRadius.circular(5),
//         color: Colors.white,
//         child: InkWell(
//           onTap: () {
//             Get.toNamed(AppRoutes.therapistsListView,
//                 arguments: {'specialization': category});
//           },
//           splashColor: MyColors.backgroundLight,
//           highlightColor: MyColors.backgroundLight,
//           child: Column(
//             children: [
//               Image.asset(
//                 image,
//                 height: 50,
//                 width: 50,
//               ),
//               Text(label, overflow: TextOverflow.ellipsis,),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Expanded customTherapistTileWidget() {
//     return Expanded(
//       child: StreamBuilder<QuerySnapshot>(
//         stream: _therapistsStream,
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return const Text('Something went wrong');
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: SizedBox(
//                 height: 50,
//                 width: 50,
//                 child: CircularProgressIndicator(
//                   color: MyColors.greenDark,
//                 ),
//               ),
//             );
//           }

//           return ListView(
//             padding: EdgeInsets.zero,
//             children:
//                 snapshot.data!.docs.take(3).map((DocumentSnapshot document) {
//               Map<String, dynamic> data =
//                   document.data()! as Map<String, dynamic>;
//               return CustomListTileWidget(data: data);
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }

//   // Appointments List
//   Widget customAppointmentsListWidget() {
//     final therapistId = firebaseService.getCurrentUser()?.uid;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
//           child: Text(
//             "Your Appointment History",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: MyColors.textPrimary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('appointments')
//                 .where('therapist_id', isEqualTo: therapistId)
//                 .snapshots(),
//             builder:
//                 (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.hasError) {
//                 return const Center(child: Text('Error loading appointments'));
//               }
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return const Center(
//                   child: Text(
//                     'No appointments found.',
//                     style: TextStyle(fontSize: 16, color: MyColors.textPrimary),
//                   ),
//                 );
//               }

//               // Filter appointments locally for dates before today
//               final today = DateTime.now();
//               final filteredAppointments = snapshot.data!.docs.where((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 final selectedDate = DateTime.parse(data['selected_date']);
//                 return selectedDate.isBefore(today);
//               }).toList();

//               if (filteredAppointments.isEmpty) {
//                 return const Center(
//                   child: Text(
//                     'No past appointments found.',
//                     style: TextStyle(fontSize: 16, color: MyColors.textPrimary),
//                   ),
//                 );
//               }

//               return ListView.builder(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 itemCount: filteredAppointments.length,
//                 itemBuilder: (context, index) {
//                   final appointment = filteredAppointments[index].data()
//                       as Map<String, dynamic>;
//                   String formatDate(String timestamp) {
//                     try {
//                       // Parse the timestamp string to a DateTime object
//                       final date = DateTime.parse(timestamp);
//                       // Format the date as 'dd MMM, yyyy' (e.g., '30 Dec, 2024')
//                       return DateFormat('d MMM, yyyy').format(date);
//                     } catch (e) {
//                       // Return 'Invalid Date' if parsing fails
//                       return 'Invalid Date';
//                     }
//                   }

//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8.0),
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 backgroundColor:
//                                     MyColors.buttonSecondary.withOpacity(0.2),
//                                 child: const Icon(
//                                   Icons.calendar_today,
//                                   color: MyColors.textPrimary,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       appointment["patient_name"] ??
//                                           'Unknown Patient',
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: MyColors.textPrimary,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               const Icon(Icons.date_range, size: 20),
//                               const SizedBox(width: 10),
//                               Text(
//                                 "Date: ${formatDate(appointment['selected_date'])}",
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: MyColors.textPrimary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             children: [
//                               const Icon(Icons.access_time, size: 20),
//                               const SizedBox(width: 10),
//                               Text(
//                                 "Time: ${appointment['selected_time']}",
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: MyColors.textPrimary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             children: [
//                               const Icon(Icons.location_on, size: 20),
//                               const SizedBox(width: 10),
//                               Text(
//                                 "Location: ${appointment['therapist_address']}",
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: MyColors.textPrimary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           const Row(
//                             children: [
//                               Icon(Icons.info, size: 20),
//                               SizedBox(width: 10),
//                               Text(
//                                 "Status: Completed",
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (appointment.containsKey("rating")) ...[
//                             const SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 const Icon(Icons.rate_review_outlined,
//                                     size: 20, color: Colors.grey),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   "Patient Rating:",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                     color: MyColors.textPrimary,
//                                   ),
//                                 ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: List.generate(5, (index) {
//                                     return Icon(
//                                       index + 1 <= appointment['rating']
//                                           ? Icons.star
//                                           : Icons.star_border,
//                                       color: Colors.amber,
//                                     );
//                                   }),
//                                 ),
//                               ],
//                             ),
//                           ]
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
