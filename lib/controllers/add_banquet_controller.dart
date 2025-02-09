import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddBanquetController extends GetxController {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final capacityController = TextEditingController();
  final priceController = TextEditingController();
  final amenitiesController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final amenityController = TextEditingController(); // For adding amenities
  final ImagePicker _picker = ImagePicker();

  var selectedImages = <dynamic>[].obs;
  var encodedImages = <dynamic>[].obs;
  var amenitiesList = <String>[].obs;
  var isLoading = false.obs;

  void addAmenity() {
    if (amenityController.text.trim().isNotEmpty) {
      amenitiesList.add(amenityController.text.trim());
      amenityController.clear();
    }
  }

  /// Function to remove an amenity
  void removeAmenity(int index) {
    amenitiesList.removeAt(index);
  }

  /// Function to pick multiple images
  Future<void> pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    for (var file in pickedFiles) {
      File imageFile = File(file.path);
      selectedImages.add(imageFile);
      encodeImageToBase64(imageFile);
    }
  }

  void encodeImageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64String = base64Encode(imageBytes);
    encodedImages.add(base64String);
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    encodedImages.removeAt(index);
  }

  /// Save banquet data to Firestore
  Future<void> saveBanquet() async {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        addressController.text.isEmpty ||
        capacityController.text.isEmpty ||
        priceController.text.isEmpty ||
        latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty ||
        encodedImages.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading(true);

    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection("banquets").doc();

      await docRef.set({
        "id": docRef.id,
        "banquet_id": docRef.id,
        "name": nameController.text.trim(),
        "description": descriptionController.text.trim(),
        "location": {
          "address": addressController.text.trim(),
          "latitude": double.tryParse(latitudeController.text) ?? 0.0,
          "longitude": double.tryParse(longitudeController.text) ?? 0.0,
        },
        "capacity": capacityController.text.trim(),
        "price_per_day": priceController.text.trim(),
        "amenities": amenitiesList.isNotEmpty ? amenitiesList : [],
        "images": encodedImages.toList(),
        "created_at": FieldValue.serverTimestamp(),
        "owner_id": FirebaseAuth.instance.currentUser?.uid,
        "not_available": [],
        "ratings": {
          "average": 0.0,
          "reviews": 0,
          "total_review": 0,
        },
      });

      Get.snackbar("Success", "Banquet added successfully!", backgroundColor: Colors.green, colorText: Colors.white);
      clearForm();
    } catch (e) {
      Get.snackbar("pado", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    addressController.clear();
    capacityController.clear();
    priceController.clear();
    latitudeController.clear();
    longitudeController.clear();
    amenitiesList.clear();
    selectedImages.clear();
    encodedImages.clear();
  }

  void setBanquetData(Map<String, dynamic> banquet) {
    nameController.text = banquet['name'];
    descriptionController.text = banquet['description'];
    addressController.text = banquet['location']['address'];
    latitudeController.text = banquet['location']['latitude'].toString();
    longitudeController.text = banquet['location']['longitude'].toString();
    capacityController.text = banquet['capacity'].toString();
    priceController.text = banquet['price_per_day'].toString();
    amenitiesList.assignAll(List<String>.from(banquet['amenities']));
    encodedImages.assignAll(banquet['images'].map((e) {
    if (e.startsWith('http')) {
      return e; // Keep URLs as they are
    } else {
      Uint8List bytes = base64Decode(e); // Decode Base64
      return MemoryImage(bytes); // Convert to ImageProvider
    }
  }).toList());
    selectedImages.assignAll(banquet['images'].map((e) {
    if (e.startsWith('http')) {
      return e; // Keep URLs as they are
    } else {
      Uint8List bytes = base64Decode(e); // Decode Base64
      return MemoryImage(bytes); // Convert to ImageProvider
    }
  }).toList());
  }

  Future<void> saveOrUpdateBanquet(String? id) async {
    if (id == null) {
      await saveBanquet();
    } else {
      await updateBanquet(id);
    }
  }

Future<void> updateBanquet(String id) async {
  if (nameController.text.isEmpty ||
      descriptionController.text.isEmpty ||
      addressController.text.isEmpty ||
      capacityController.text.isEmpty ||
      priceController.text.isEmpty ||
      latitudeController.text.isEmpty ||
      longitudeController.text.isEmpty ||
      encodedImages.isEmpty) {
    Get.snackbar("Error", "Please fill all required fields", backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }

  isLoading(true);

  try {
    // Convert all images to Base64 or keep URLs
    List<String> finalImages = encodedImages.map((image) {
      if (image is String) {
        return image; // Keep URLs as they are
      } else if (image is MemoryImage) {
        // Extract bytes and encode as Base64
        return base64Encode(image.bytes);
      } else {
        return ''; // Ignore invalid values
      }
    }).where((image) => image.isNotEmpty).toList(); // Remove empty strings

    await FirebaseFirestore.instance.collection("banquets").doc(id).update({
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "location": {
        "address": addressController.text.trim(),
        "latitude": double.tryParse(latitudeController.text) ?? 0.0,
        "longitude": double.tryParse(longitudeController.text) ?? 0.0,
      },
      "capacity": capacityController.text.trim(),
      "price_per_day": priceController.text.trim(),
      "amenities": amenitiesList.isNotEmpty ? amenitiesList : [],
      "images": finalImages, // Store valid image strings (URLs or Base64)
      "updated_at": FieldValue.serverTimestamp(),
    });

    Get.snackbar("Success", "Banquet updated successfully!", backgroundColor: Colors.green, colorText: Colors.white);
    Navigator.pop(Get.context!);
  } catch (e) {
    Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
  } finally {
    isLoading(false);
  }
}


}
