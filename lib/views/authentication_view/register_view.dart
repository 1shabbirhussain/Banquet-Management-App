import 'package:event_ease/controllers/auth_controller.dart';
import 'package:event_ease/custom_widgets/custom_dropdown.dart';
import 'package:event_ease/custom_widgets/custom_text_field.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/utils/validation_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = Get.find();

  void _validateAndSignUp() {
    _authController.signUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            _buildHeader(context),
            _buildForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 0.6,
          colors: [
            MyColors.backgroundLight,
            MyColors.backgroundDark,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(100),
          bottomRight: Radius.circular(100),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset('assets/images/logo.png', fit: BoxFit.cover, height: 150),
          const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    double topPadding =
        isKeyboardVisible ? 80 : MediaQuery.of(context).size.height * 0.15;
    return Form(
      key: _authController.formKey,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Center(
          child: Card(
            elevation: 30,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Register as",
                      style: TextStyle(
                        color: MyColors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _buildRoleSelection(),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _authController.nameController,
                      label: "Full Name",
                      hintText: "Enter your full name",
                      inputType: TextInputType.name,
                      validator: (value) => value!.validateNotEmpty(),
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _authController.emailController,
                      label: "Email",
                      hintText: "Enter your email",
                      inputType: TextInputType.emailAddress,
                      validator: (value) => value!.validateEmail(),
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _authController.phoneController,
                      label: "Phone Number",
                      hintText: "Enter your phone number",
                      inputType: TextInputType.phone,
                      validator: (value) => value!.validatePhoneNumber(),
                      maxLength: 11,
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _authController.passwordController,
                      label: "Password",
                      hintText: "Enter your password",
                      isPasswordField: true,
                      validator: (value) => value!.validateStrongPassword(),
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _authController.confirmPasswordController,
                      label: "Confirm Password",
                      hintText: "Confirm your password",
                      isPasswordField: true,
                      validator: (value) => value!.validateConfirmPassword(
                        _authController.passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown(
                      label: "Select your city",
                      hintText: "Select your city",
                      items: cities,
                      onChanged: (value) {
                      _authController.selectedCity.value = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildGenderSelection(),
                    const SizedBox(height: 20),
                    _buildTermsAndConditions(),
                    const SizedBox(height: 10),
                    _buildRegisterButton(),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        "Go to Login screen",
                        style: TextStyle(
                          color: MyColors.textPrimary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRoleButton("Venue Owner", Icons.store_mall_directory_outlined),
        const SizedBox(width: 20),
        _buildRoleButton("Venue Booker", Icons.event),
      ],
    );
  }

  Widget _buildRoleButton(String role, IconData icon) {
    return Obx(() => Expanded(
          child: GestureDetector(
            onTap: () {
              _authController.selectedRole.value = role;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                color: _authController.selectedRole.value == role
                    ? MyColors.buttonSecondary
                    : MyColors.buttonPrimary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: _authController.selectedRole.value == role
                    ? [
                        BoxShadow(
                          color: MyColors.buttonSecondary.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Icon( icon,
                      color: _authController.selectedRole.value == role
                          ? MyColors.textWhite
                          : MyColors.primary,
                      size: 28),
                  FittedBox(
                    child: Center(
                      child: Text(
                        role,
                        style: TextStyle(
                            color: _authController.selectedRole.value == role
                                ? MyColors.textWhite
                                : MyColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildGenderSelection() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text("Male"),
              value: "Male",
              groupValue: _authController.genderController.value,
              onChanged: (value) {
                _authController.genderController.value = value!;
              },
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text("Female"),
              value: "Female",
              groupValue: _authController.genderController.value,
              onChanged: (value) {
                _authController.genderController.value = value!;
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTermsAndConditions() {
    return Obx(() => Row(
          children: [
            Checkbox(
              value: _authController.termsAccepted.value,
              onChanged: (value) {
                _authController.termsAccepted.value = value!;
              },
              activeColor: MyColors.buttonSecondary,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _authController.termsAccepted.value =
                      !_authController.termsAccepted.value;
                },
                child: const Text(
                  "I agree to the Terms and Conditions",
                  style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    color: MyColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.maxFinite,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonSecondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: _validateAndSignUp,
        child: const Text(
          "Register",
          style: TextStyle(color: MyColors.textWhite),
        ),
      ),
    );
  }

  List<String> cities = [
    "Karachi",
    "Lahore",
    "Islamabad",
    "Rawalpindi",
    "Faisalabad",
    "Multan",
    "Peshawar",
    "Quetta",
    "Sialkot",
    "Gujranwala",
    "Hyderabad",
    "Sukkur",
    "Bahawalpur",
    "Sargodha",
    "Mardan",
    "Sheikhupura",
    "Gujrat",
    "Larkana",
    "Kasur",
    "Rahim Yar Khan",
  ];
}
