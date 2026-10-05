import 'package:intl/intl.dart';

// ─── Currency Formatting ───────────────────────────────────
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  return formatter.format(amount);
}

String formatCurrencyCompact(double amount) {
  if (amount >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '₹${(amount / 1000).toStringAsFixed(1)}K';
  }
  return formatCurrency(amount);
}

// ─── Date Formatting ───────────────────────────────────────
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}

String formatDateShort(DateTime date) {
  return DateFormat('dd/MM').format(date);
}

// ─── Date Helpers ──────────────────────────────────────────
bool isExpiringSoon(DateTime? expiryDate, {int withinDays = 7}) {
  if (expiryDate == null) return false;
  final now = DateTime.now();
  final difference = expiryDate.difference(now).inDays;
  return difference >= 0 && difference <= withinDays;
}

bool isExpired(DateTime? expiryDate) {
  if (expiryDate == null) return false;
  return expiryDate.isBefore(DateTime.now());
}

int daysUntilExpiry(DateTime? expiryDate) {
  if (expiryDate == null) return -1;
  return expiryDate.difference(DateTime.now()).inDays;
}

bool isDeadStock(DateTime? lastSoldAt, {int days = 30}) {
  if (lastSoldAt == null) return true; // never sold
  return DateTime.now().difference(lastSoldAt).inDays >= days;
}

// ─── Validation Helpers ────────────────────────────────────
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}

String? validatePositiveNumber(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return '$fieldName is required';
  }
  final number = double.tryParse(value);
  if (number == null || number < 0) {
    return 'Enter a valid $fieldName';
  }
  return null;
}

String? validateNonNegativeInt(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return '$fieldName is required';
  }
  final number = int.tryParse(value);
  if (number == null || number < 0) {
    return 'Enter a valid whole number for $fieldName';
  }
  return null;
}

// ─── Misc ──────────────────────────────────────────────────
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

String getDayLabel(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}
