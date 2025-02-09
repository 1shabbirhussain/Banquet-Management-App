extension StringValidators on String {
  // Check if the field is empty and return an error message
  String? validateNotEmpty({String errorMessage = "This field cannot be empty"}) {
    return trim().isEmpty ? errorMessage : null;
  }

  // Check if the string is a valid email
  String? validateEmail({String errorMessage = "Please enter a valid email"}) {
    return RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(this)
        ? null
        : errorMessage;
  }

  // Check if the string is a strong password
  String? validateStrongPassword() {
    if (length < 8) {
      return "Password must be at least 8 characters long";
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(this)) {
      return "Password must contain at least one lowercase letter";
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(this)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(this)) {
      return "Password must contain at least one number";
    }
    return null;
  }


  String? validateLatitude() {
    if (trim().isEmpty) {
      return "Latitude is required";
    }
    double? value = double.tryParse(this);
    if (value == null || value < -90 || value > 90) {
      return "Enter a valid latitude (-90 to 90)";
    }
    return null;
  }

  String? validateLongitude() {
    if (trim().isEmpty) {
      return "Longitude is required";
    }
    double? value = double.tryParse(this);
    if (value == null || value < -180 || value > 180) {
      return "Enter a valid longitude (-180 to 180)";
    }
    return null;
  }

  // Check if the string is a valid phone number
  String? validatePhoneNumber({String errorMessage = "Please enter a valid phone number"}) {
    return RegExp(r"^(?:[+0]9)?[0-9]{11}$").hasMatch(this) ? null : errorMessage;
  }

  // Check if the string has a minimum length
  String? validateMinLength(int minLength, {String? errorMessage}) {
    return length >= minLength ? null : (errorMessage ?? "Minimum $minLength characters required");
  }

  // Check if the string matches an exact length
  String? validateExactLength(int exactLength, {String? errorMessage}) {
    return length == exactLength
        ? null
        : (errorMessage ?? "Must be exactly $exactLength characters long");
  }
    // Validate confirm password by comparing with another password
  String? validateConfirmPassword(String password, {String errorMessage = "Passwords do not match"}) {
    return this == password ? null : errorMessage;
  }
}
