import 'dart:convert';

import 'package:event_ease/controllers/bokker_home_controller.dart';
import 'package:event_ease/custom_widgets/custom_drawer.dart';
import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/services/firebase_services.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';


class BookerHome extends StatelessWidget {
  BookerHome({super.key});

  final TextEditingController _searchController = TextEditingController();
  final FirebaseService firebaseService = FirebaseService();

  // GetX Controller
  final BanquetController controller = Get.put(BanquetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose your Banquet",
          style: TextStyle(color: MyColors.textSecondary),
        ),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.bars,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.bell,
              color: Colors.white,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.notificationScreen);
            },
          )
        ],
      ),
      drawer: Obx(
        () => CustomDrawer(
          userName: controller.userName.value,
          userEmail: controller.userEmail.value,
          profilePictureUrl: controller.profilePictureUrl.value,
          isOwner: false,
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Widget
          searchAndFilterWidget(),

          // Pull-to-Refresh and List of Banquets
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.fetchBanquets(); // Pull-to-refresh action
              },
              child: Obx(() {
                if (controller.filteredBanquets.isEmpty) {
                  return const Center(
                    child: Text(
                      "No results found. Try adjusting your filters.",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.filteredBanquets.length,
                  itemBuilder: (context, index) {
                    final banquet = controller.filteredBanquets[index].data()
                        as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.banquetDetailScreen,
                          arguments: {
                            'banquet': banquet,
                            "hideButton": false,
                          },
                        );
                      },
                      child: BanquetCard(banquet: banquet),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// **SEARCH BAR & FILTER BUTTON**
  Widget searchAndFilterWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Banquets...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                controller.searchBanquets(value);
              },
            ),
          ),
          const SizedBox(width: 10),

          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            color: MyColors.accent,
            onPressed: () {
              showFilterDialog();
            },
          ),
        ],
      ),
    );
  }

  /// **FILTER DIALOG BOX (With Radio Buttons for Sorting)**
  void showFilterDialog() {
    Get.defaultDialog(
      title: "Sort Banquets",
      content: Obx(
        () => Column(
          children: [
            // Sort By Name
            ListTile(
              title: const Text("Name: A → Z"),
              leading: Radio<String>(
                value: 'name_asc',
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) =>
                    controller.selectedSortOption.value = value!,
              ),
            ),
            ListTile(
              title: const Text("Name: Z → A"),
              leading: Radio<String>(
                value: 'name_desc',
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) =>
                    controller.selectedSortOption.value = value!,
              ),
            ),

            // Sort By Price
            ListTile(
              title: const Text("Price: Low → High"),
              leading: Radio<String>(
                value: 'price_asc',
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) =>
                    controller.selectedSortOption.value = value!,
              ),
            ),
            ListTile(
              title: const Text("Price: High → Low"),
              leading: Radio<String>(
                value: 'price_desc',
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) =>
                    controller.selectedSortOption.value = value!,
              ),
            ),

            // Sort By Rating
            ListTile(
              title: const Text("Rating: High → Low"),
              leading: Radio<String>(
                value: 'rating_high',
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) =>
                    controller.selectedSortOption.value = value!,
              ),
            ),
            ListTile(
              title: const Text("Rating: Low → High"),
              leading: Radio<String>(
                value: 'rating_low',
                groupValue: controller.selectedSortOption.value,
                onChanged: (value) =>
                    controller.selectedSortOption.value = value!,
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          controller.applyFilters();
          Get.back();
        },
        child: const Text("Apply"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }
}

class BanquetCard extends StatelessWidget {
  final Map<String, dynamic> banquet;

  const BanquetCard({super.key, required this.banquet});

  @override
  Widget build(BuildContext context) {
    final String name = banquet['name'] ?? 'Unknown';
    final String imageUrl =
        banquet['images'] != null && banquet['images'].isNotEmpty
            ? banquet['images'][0]
            : 'https://via.placeholder.com/150';
    final double rating =
        banquet['ratings'] != null && banquet['ratings']['average'] != null
            ? banquet['ratings']['average'].toDouble()
            : 0.0;
    final String location = banquet['location'] != null
        ? banquet['location']['address'] ?? 'Unknown location'
        : 'Unknown location';
    final String price = banquet['price_per_day'] ?? 'N/A';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banquet Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: imageUrl.startsWith('http')
                ? Image.network(imageUrl,
                    height: 120, width: double.infinity, fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Skeletonizer(
                      enabled: true,
                      enableSwitchAnimation: true,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                    );
                  })
                : Image.memory(
                    base64Decode(imageUrl),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),

          // Banquet Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1)),
                      ],
                    ),
                    FittedBox(
                      child: Text(
                        "Rs.$price/day",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
