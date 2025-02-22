import 'package:event_ease/controllers/auth_controller.dart';
import 'package:event_ease/custom_widgets/custom_text_field.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/utils/validation_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerLoginScreen extends StatelessWidget {
  OwnerLoginScreen({super.key});

  final AuthController _authController = Get.put<AuthController>(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            _buildHeader(context),
            _buildLoginForm(context),
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

  Widget _buildLoginForm(context) {
    return Center(
      child: Card(
        elevation: 30,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.45,
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .store_mall_directory_outlined, // Icon indicating a Venue Booker
                    color: MyColors.green,
                    size: 28,
                  ),
                  SizedBox(width: 8), // Space between icon and text
                  Text(
                    "Owner Login",
                    style: TextStyle(
                      color: MyColors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              _textFieldsWidget(),
              _buildSignInButton(),
              _buildFooterLinks(context),
            ],
          ),
        ),
      ),
    );
  }

  Column _textFieldsWidget() {
    return Column(
      children: [
        CustomTextFormField(
          controller: _authController.ownerLoginEmailController,
          label: "Email",
          hintText: "Enter your email",
          inputType: TextInputType.emailAddress,
          prefixIcon: Icons.email,
          validator: (value) => value!.validateEmail(),
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: _authController.ownerLoginPasswordController,
          label: "Password",
          hintText: "Enter your password",
          isPasswordField: true,
          prefixIcon: Icons.lock,
          validator: (value) => value!.validateNotEmpty(),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonSecondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => _authController.signIn('Venue Owner', isOwner: true),
        child:
            const Text("Sign In", style: TextStyle(color: MyColors.textWhite)),
      ),
    );
  }

  Widget _buildFooterLinks(context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.bookerLogin),
          child: const Text(
            "Login as a Venue Booker",
            style: TextStyle(
              color: MyColors.textPrimary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.register),
          child: const Text(
            "Don't have an account? Register",
            style: TextStyle(
              color: MyColors.textPrimary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
