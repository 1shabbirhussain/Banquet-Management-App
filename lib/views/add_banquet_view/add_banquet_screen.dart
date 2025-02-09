import 'dart:io';

import 'package:event_ease/controllers/add_banquet_controller.dart';
import 'package:event_ease/custom_widgets/custom_text_field.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/utils/validation_extension.dart';
import 'package:event_ease/views/add_banquet_view/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBanquetScreen extends GetView<AddBanquetController> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic>? banquet;
  AddBanquetScreen({super.key}) : banquet = Get.arguments['banquet'] as Map<String, dynamic>?;

  @override
  Widget build(BuildContext context) {
    // Pass banquet data to controller if in edit mode
    if (banquet != null) {
      controller.setBanquetData(banquet!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          banquet == null ? "Add Banquet" : "Edit Banquet",
          style: const TextStyle(color: MyColors.textSecondary),
        ),
        backgroundColor: MyColors.backgroundDark,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                CustomTextFormField(
                  controller: controller.nameController,
                  label: "Banquet Name",
                  hintText: "Enter banquet name",
                  inputType: TextInputType.text,
                  validator: (value) => value!.validateNotEmpty(),
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: controller.descriptionController,
                  label: "Description",
                  hintText: "Enter banquet description",
                  inputType: TextInputType.text,
                  validator: (value) => value!.validateNotEmpty(),
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: controller.addressController,
                  label: "Address",
                  hintText: "Enter banquet address",
                  inputType: TextInputType.text,
                  validator: (value) => value!.validateNotEmpty(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: controller.latitudeController,
                        label: "Latitude",
                        hintText: "Enter latitude",
                        inputType: TextInputType.number,
                        validator: (value) => value!.validateLatitude(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextFormField(
                        controller: controller.longitudeController,
                        label: "Longitude",
                        hintText: "Enter longitude",
                        inputType: TextInputType.number,
                        validator: (value) => value!.validateLongitude(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: controller.capacityController,
                  label: "Capacity",
                  hintText: "Enter capacity",
                  inputType: TextInputType.number,
                  validator: (value) => value!.validateNotEmpty(),
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: controller.priceController,
                  label: "Price per day",
                  hintText: "Enter price",
                  inputType: TextInputType.number,
                  validator: (value) => value!.validateNotEmpty(),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Amenities", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: controller.amenityController,
                            label: "Add Amenity",
                            hintText: "Enter an amenity",
                            inputType: TextInputType.text,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CustomElevatedButton(
                          onTap: controller.addAmenity,
                          title: "Add",
                          width: MediaQuery.sizeOf(context).width * 0.2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.amenitiesList.map((amenity) {
                            int index = controller.amenitiesList.indexOf(amenity);
                            return Chip(
                              label: Text(amenity),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () => controller.removeAmenity(index),
                              backgroundColor: Colors.blue[100],
                            );
                          }).toList(),
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(() => SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return GestureDetector(
                              onTap: controller.pickImages,
                              child: Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: MyColors.buttonSecondary,
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 30, color: MyColors.buttonPrimary),
                                    SizedBox(height: 5),
                                    Text("Add Images", style: TextStyle(color: MyColors.textWhite)),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            int imageIndex = index - 1;
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: controller.selectedImages[imageIndex] is String
                                          ? NetworkImage(controller.selectedImages[imageIndex]) as ImageProvider // Case 1: URL
                                          : controller.selectedImages[imageIndex] is MemoryImage
                                              ? controller.selectedImages[imageIndex] as ImageProvider // Case 2: Base64
                                              : FileImage(controller.selectedImages[imageIndex] as File), // Case 3: Local file
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => controller.removeImage(imageIndex),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    )),
                const SizedBox(height: 20),
                Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : CustomElevatedButton(
                        width: MediaQuery.sizeOf(context).width * 0.5,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            controller.saveOrUpdateBanquet(banquet?['id']);
                          }
                        },
                        title: banquet == null ? "Create Banquet" : "Update Banquet",
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
