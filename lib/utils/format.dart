/// Formats a number as Philippine pesos, e.g. 4999 → "₱4,999".
String peso(num value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '₱$buffer';
}
