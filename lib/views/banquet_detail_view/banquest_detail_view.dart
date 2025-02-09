import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/views/add_banquet_view/custom_elevated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_ease/utils/colors.dart';

class BanquetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> banquet;
  final bool hideButton;

  BanquetDetailScreen({super.key, required this.banquet, required this.hideButton});

  final isDeleting = false.obs; // Observed state for delete progress

  Future<void> deleteBanquet(String banquetID) async {
    isDeleting.value = true;
    try {
      await FirebaseFirestore.instance.collection('banquets').doc(banquetID).delete();
      Get.snackbar("Success", "Banquet deleted successfully!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete banquet", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isDeleting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = (banquet['images'] ?? []).cast<String>();
    final String name = banquet['name'] ?? 'Unknown';
    final String description = banquet['description'] ?? 'No description available.';
    final String location = banquet['location']?['address'] ?? 'Location not available';
    final double latitude = banquet['location']?['latitude'] ?? 0.0;
    final double longitude = banquet['location']?['longitude'] ?? 0.0;
    final String capacity = banquet['capacity'] ?? 'N/A';
    final String price = banquet['price_per_day'] ?? 'N/A';
    final double rating = banquet['ratings']?['average']?.toDouble() ?? 0.0;
    final int reviews = banquet['ratings']?['reviews'] ?? 0;
    final List<String> amenities = (banquet['amenities'] ?? ['No amenities']).cast<String>();
    final String ownerID = banquet['owner_id'] ?? '';
    final String banquetID = banquet['id'] ?? '';

    return Scaffold(
        appBar: AppBar(
          title: Text(name, style: const TextStyle(color: MyColors.textSecondary)),
          centerTitle: true,
          backgroundColor: MyColors.backgroundDark,
          iconTheme: const IconThemeData(color: MyColors.textSecondary),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              carouselSliderWidget(images),
              const SizedBox(height: 20),

              // Details Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: MyColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(width: 4),
                            Text("($reviews reviews)",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_pin, color: MyColors.buttonSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.showLocationMap, arguments: {
                              'latitude': latitude,
                              'longitude': longitude,
                              'name': name,
                            });
                          },
                          child: const Text(
                            "Show on Map",
                            style: TextStyle(
                              color: MyColors.buttonSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      "Description:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    // Capacity and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Capacity:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.group, color: MyColors.textPrimary, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "$capacity Guests",
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Price Per Day:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "Rs. $price",
                                  style: const TextStyle(fontSize: 16, color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Amenities Section
                    const Text(
                      "Amenities:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: amenities.map((amenity) {
                        return Row(
                          children: [
                            const Icon(Icons.check_circle, color: MyColors.textPrimary, size: 16),
                            const SizedBox(width: 8),
                            Text(amenity, style: const TextStyle(fontSize: 16)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: !hideButton
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ownerID == FirebaseAuth.instance.currentUser?.uid) ...[
                    Obx(
                      () => isDeleting.value
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomElevatedButton(
                                  onTap: () {},
                                  title: "Edit",
                                  width: MediaQuery.of(context).size.width * 0.40,
                                ),
                                const SizedBox(width: 50),
                                CustomElevatedButton(
                                  onTap: () async {
                                    await deleteBanquet(banquetID);
                                  },
                                  title: "Delete",
                                  width: MediaQuery.of(context).size.width * 0.40,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.transparent,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.buttonSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          // Booking page logic
                          Get.toNamed(AppRoutes.bookingScreen, arguments: {'banquet': banquet});
                        },
                        child: const Text(
                          "Book Now",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    )
                ],
              )
            : const SizedBox.shrink());
  }

  //==============================WIDGETS===============================

  CarouselSlider carouselSliderWidget(List<String> images) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
      ),
      items: images.isNotEmpty
          ? images.map((imageUrl) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl.startsWith("http")
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.memory(
                        base64Decode(imageUrl),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              );
            }).toList()
          : [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/placeholder.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ],
    );
  }
}
