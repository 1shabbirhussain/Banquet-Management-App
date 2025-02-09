import 'dart:async';
import 'dart:convert';
import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/views/add_banquet_view/custom_elevated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManageBanquetsScreen extends StatefulWidget {
  const ManageBanquetsScreen({super.key});

  @override
  State<ManageBanquetsScreen> createState() => _BanquetListPageState();
}

class _BanquetListPageState extends State<ManageBanquetsScreen> {
  String searchQuery = "";
  double? minPrice;
  double? maxPrice;
  List<DocumentSnapshot> allBanquets = [];
  List<DocumentSnapshot> filteredBanquets = [];
  Timer? _debounce;
  bool isLoading = true; // Track loading state

  void applyFilters() {
    setState(() {
      filteredBanquets = allBanquets.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name']?.toString().toLowerCase() ?? "";
        final price = double.tryParse(data['price_per_day'] ?? "0") ?? 0.0;

        final matchesSearch = searchQuery.isEmpty || name.contains(searchQuery.toLowerCase());
        final matchesPrice = (minPrice == null || price >= minPrice!) && (maxPrice == null || price <= maxPrice!);

        return matchesSearch && matchesPrice;
      }).toList();
      isLoading = false; // Stop skeleton once filtering is done
    });
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value;
        applyFilters();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Banquets", style: TextStyle(color: MyColors.textSecondary)),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('banquets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("An error occurred while fetching banquets."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No banquets available."));
          }

          final newBanquets = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['owner_id'] == FirebaseAuth.instance.currentUser?.uid;
          }).toList();

          // Only update state if the new data is different
          if (allBanquets.length != newBanquets.length) {
            allBanquets = newBanquets;
            isLoading = true; // Show loading before filtering
            WidgetsBinding.instance.addPostFrameCallback((_) {
              applyFilters();
            });
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: searchAndFilterWidget(context),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator()) // 🔥 Avoids Skeletonizer stuck issue
                    : filteredBanquets.isEmpty
                        ? const Center(child: Text("No matching banquets found."))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: filteredBanquets.length,
                            itemBuilder: (context, index) {
                              final banquet = filteredBanquets[index].data() as Map<String, dynamic>;
                              return GestureDetector(
                                  onTap: () {
                                    Get.toNamed(AppRoutes.banquetDetailScreen,
                                        arguments: {'banquet': banquet, "hideButton": false});
                                  },
                                  child: BanquetCard(banquet: banquet));
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget searchAndFilterWidget(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search Banquets...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: onSearchChanged,
    );
  }
}



class BanquetCard extends StatefulWidget {
  final double? imageHeight;
  final double? imageWidth;
  final double? cardHeight;
  final double? cardWidth;
  final double? buttonHeight;
  final double? buttonWidth;
  final Map<String, dynamic> banquet;

  const BanquetCard({
    required this.banquet,
    super.key,
    this.imageHeight,
    this.imageWidth,
    this.cardHeight,
    this.cardWidth,
    this.buttonHeight,
    this.buttonWidth,
  });

  @override
  BanquetCardState createState() => BanquetCardState();
}

class BanquetCardState extends State<BanquetCard> {
  var isDeleting = false.obs; // Observed state for delete progress

  Future<void> deleteBanquet() async {
    isDeleting.value = true;
    try {
      await FirebaseFirestore.instance.collection('banquets').doc(widget.banquet['id']).delete();
      Get.snackbar("Success", "Banquet deleted successfully!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete banquet", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isDeleting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.banquet['name'] ?? 'Unknown';
    final String imageUrl = widget.banquet['images'] != null && widget.banquet['images'].isNotEmpty
        ? widget.banquet['images'][0]
        : 'https://via.placeholder.com/150';
    final double rating = widget.banquet['ratings'] != null && widget.banquet['ratings']['average'] != null
        ? widget.banquet['ratings']['average'].toDouble()
        : 0.0;
    final String location =
        widget.banquet['location'] != null ? widget.banquet['location']['address'] ?? 'Unknown location' : 'Unknown location';
    final String price = widget.banquet['price_per_day'] ?? 'N/A';

    return SizedBox(
      width: widget.cardWidth,
      height: widget.cardHeight,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banquet Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: imageUrl.startsWith('http')
                    ? Image.network(imageUrl,
                        height: widget.imageHeight ?? 120, width: widget.imageWidth ?? double.infinity, fit: BoxFit.cover)
                    : Image.memory(base64Decode(imageUrl),
                        height: widget.imageHeight ?? 120, width: widget.imageWidth ?? double.infinity, fit: BoxFit.cover),
              ),
            ),

            // Banquet Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: Text(name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    child:
                        Text(location, style: const TextStyle(fontSize: 14, color: Colors.grey), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(rating.toStringAsFixed(1)),
                        ],
                      ),
                      FittedBox(
                        child: Text(
                          "Rs.$price/day",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Delete Button or Progress Indicator
                  Obx(
                    () => isDeleting.value
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomElevatedButton(
                                onTap: () {
                                  Get.toNamed(AppRoutes.addBanquetScreen, arguments: {'banquet': widget.banquet});
                                },
                                title: "Edit",
                                width: widget.buttonWidth ?? MediaQuery.of(context).size.width * 0.40,
                                height: widget.buttonHeight,
                              ),
                              // const SizedBox(width: 10),
                              CustomElevatedButton(
                                onTap: deleteBanquet,
                                title: "Delete",
                                width: widget.buttonWidth ?? MediaQuery.of(context).size.width * 0.40,
                                height: widget.buttonHeight,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
