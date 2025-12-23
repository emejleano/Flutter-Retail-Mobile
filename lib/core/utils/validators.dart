class Validators {
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? minLength(String? value, int length, [String fieldName = 'Field']) {
    if (value == null || value.length < length) {
      return '$fieldName must be at least $length characters';
    }
    return null;
  }
  
  static String? maxLength(String? value, int length, [String fieldName = 'Field']) {
    if (value != null && value.length > length) {
      return '$fieldName must not exceed $length characters';
    }
    return null;
  }
  
  static String? numeric(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }
  
  static String? positiveNumber(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number < 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }
  
  static String? percentage(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number < 0 || number > 1) {
      return '$fieldName must be between 0 and 1';
    }
    return null;
  }
  
  static String? minValue(String? value, double min, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number < min) {
      return '$fieldName must be at least $min';
    }
    return null;
  }
  
  static String? integer(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) return null;
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName must be a whole number';
    }
    return null;
  }
  
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) return result;
    }
    return null;
  }
}
