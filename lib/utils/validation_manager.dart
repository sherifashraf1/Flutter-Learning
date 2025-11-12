class ValidationManager {
  static String? name(String? value, {String fieldName = "Field"}) {
    if (value == null || value.isEmpty) return "$fieldName is required";
    if (value.length < 2) return "Please enter a valid $fieldName";
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(value)) {
      return "Please enter a valida email";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password too short";
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) return "Passwords don't match";
    return null;
  }
}