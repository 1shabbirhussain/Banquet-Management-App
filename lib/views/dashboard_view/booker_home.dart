import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BookerHome extends StatefulWidget {
  const BookerHome({super.key});

  @override
  State<BookerHome> createState() => _BanquetListPageState();
}

class _BanquetListPageState extends State<BookerHome> {
  String searchQuery = "";
  double? minPrice;
  double? maxPrice;
  bool isLoading = true; // Add loading state
  List<DocumentSnapshot> allBanquets = [];
  List<DocumentSnapshot> filteredBanquets = [];

  //=====================================METHODS==============================================
  void applyFilters() {
    filteredBanquets = allBanquets.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = data['name']?.toString().toLowerCase() ?? "";
      final price = double.tryParse(data['price_per_day'] ?? "0") ?? 0.0;

      final matchesSearch = searchQuery.isEmpty || name.contains(searchQuery.toLowerCase());
      final matchesPrice = (minPrice == null || price >= minPrice!) &&
          (maxPrice == null || price <= maxPrice!);

      return matchesSearch && matchesPrice;
    }).toList();
  }
  //=====================================METHODS==============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose your Banquet", style: TextStyle(color: MyColors.textSecondary)),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('banquets').snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred while fetching banquets."),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No banquets available."),
            );
          }

          // Update the list of all banquets when data changes
          allBanquets = snapshot.data!.docs;
          applyFilters();

          return Skeletonizer(
            enabled: snapshot.connectionState == ConnectionState.waiting,
            enableSwitchAnimation: true,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: searchAndFilterWidget(context),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredBanquets.length,
                    itemBuilder: (context, index) {
                      final banquet = filteredBanquets[index].data() as Map<String, dynamic>;
            
                      return GestureDetector(
                        onTap: () {
                          // Navigate to banquet details
                          Get.toNamed(AppRoutes.banquetDetailScreen, arguments: {'banquet': banquet});
                        },
                        child: BanquetCard(banquet: banquet),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Row searchAndFilterWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search Banquets...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                applyFilters();
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.filter_list),
          color: MyColors.accent,
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              builder: (context) {
                double? tempMinPrice = minPrice;
                double? tempMaxPrice = maxPrice;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Min Price",
                            ),
                            onChanged: (value) {
                              setState(() {
                                tempMinPrice = double.tryParse(value);
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Max Price",
                            ),
                            onChanged: (value) {
                              setState(() {
                                tempMaxPrice = double.tryParse(value);
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                minPrice = tempMinPrice;
                                maxPrice = tempMaxPrice;
                              });
                              applyFilters();
                              Navigator.pop(context);
                            },
                            child: const Text("Apply Filters"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class BanquetCard extends StatelessWidget {
  final Map<String, dynamic> banquet;

  const BanquetCard({super.key, required this.banquet});

  @override
  Widget build(BuildContext context) {
    final String name = banquet['name'] ?? 'Unknown';
    final String imageUrl = banquet['images'] != null && banquet['images'].isNotEmpty
        ? banquet['images'][0]
        : 'https://via.placeholder.com/150';
    final double rating = banquet['ratings'] != null && banquet['ratings']['average'] != null
        ? banquet['ratings']['average'].toDouble()
        : 0.0;
    final String location = banquet['location'] != null ? banquet['location']['address'] ?? 'Unknown location' : 'Unknown location';
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
            child: Image.network(
              imageUrl,
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
