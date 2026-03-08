import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    if (v.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    if (v != original) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static String? latitude(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    final parsed = double.tryParse(v.trim());
    if (parsed == null || parsed < -90 || parsed > 90) {
      return 'Enter a valid latitude (-90 to 90)';
    }
    return null;
  }

  static String? longitude(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    final parsed = double.tryParse(v.trim());
    if (parsed == null || parsed < -180 || parsed > 180) {
      return 'Enter a valid longitude (-180 to 180)';
    }
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    final regex = RegExp(r'^\+?[\d\s\-]{7,15}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid contact number';
    return null;
  }
}
