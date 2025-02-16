import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BanquetController extends GetxController {
  // Reactive State Variables
  var allBanquets = <DocumentSnapshot>[].obs;
  var filteredBanquets = <DocumentSnapshot>[].obs;
  var isLoading = false.obs; // Loading indicator for pull-to-refresh

  // User Info for Drawer
  var userName = 'Guest'.obs;
  var userEmail = 'No Email'.obs;
  var profilePictureUrl = ''.obs;

  // Search and Filters
  var searchQuery = ''.obs;

  // Sort Options
  var selectedSortOption = 'name_asc'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanquets();
    fetchUserName();
  }

  // Fetch User Info for Drawer
  void fetchUserName() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userEmail.value = currentUser.email ?? 'No Email';

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('bookers')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          userName.value = data['name'] ?? 'Guest';
          profilePictureUrl.value = data.containsKey('profile_picture_base64')
              ? data['profile_picture_base64']
              : '';
        } else {
          userName.value = 'Guest';
        }
      } else {
        userName.value = 'Guest';
        userEmail.value = 'No Email';
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  // Fetch Banquets (Used in Pull-to-Refresh)
  Future<void> fetchBanquets() async {
    try {
      isLoading.value = true; // Show loading indicator
      var snapshot =
          await FirebaseFirestore.instance.collection('banquets').get();
      allBanquets.assignAll(snapshot.docs);
      filteredBanquets.assignAll(snapshot.docs);
    } catch (e) {
      print('Error fetching banquets: $e');
    } finally {
      isLoading.value = false; // Hide loading indicator
    }
  }

  // Search Banquets
  void searchBanquets(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredBanquets.assignAll(allBanquets);
    } else {
      filteredBanquets.assignAll(
        allBanquets.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  // Apply Sorting Based on Selection
  void applyFilters() {
    var tempResults = List<DocumentSnapshot>.from(allBanquets);

    tempResults.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final String aName = (aData['name'] ?? '').toString().toLowerCase();
      final String bName = (bData['name'] ?? '').toString().toLowerCase();

      final double aPrice =
          double.tryParse(aData['price_per_day']?.toString() ?? '0') ?? 0.0;
      final double bPrice =
          double.tryParse(bData['price_per_day']?.toString() ?? '0') ?? 0.0;

      final double aRating =
          (aData['ratings'] != null && aData['ratings']['average'] != null)
              ? (aData['ratings']['average']).toDouble()
              : 0.0;

      final double bRating =
          (bData['ratings'] != null && bData['ratings']['average'] != null)
              ? (bData['ratings']['average']).toDouble()
              : 0.0;

      switch (selectedSortOption.value) {
        case 'name_asc':
          return aName.compareTo(bName);
        case 'name_desc':
          return bName.compareTo(aName);
        case 'price_asc':
          return aPrice.compareTo(bPrice);
        case 'price_desc':
          return bPrice.compareTo(aPrice);
        case 'rating_high':
          return bRating.compareTo(aRating);
        case 'rating_low':
          return aRating.compareTo(bRating);
        default:
          return aName.compareTo(bName);
      }
    });

    filteredBanquets.assignAll(tempResults);
  }
}
