/// Formats a numeric price for display using the Philippine peso symbol and
/// comma-separated thousands (for example, 6890 becomes `₱6,890`).
String formatPeso(double amount) {
  final digits = amount.round().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return '₱$buffer';
}
