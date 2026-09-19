class CurrencyFormatter {
  /// Formats a number according to Indian Numbering System (e.g. ₹1,250, ₹25,000, ₹1,05,500)
  static String format(num amount, {bool showSymbol = true, bool compact = false}) {
    final symbol = showSymbol ? '₹' : '';
    final isNegative = amount < 0;
    final absVal = amount.abs();

    if (compact) {
      if (absVal >= 10000000) {
        return '$symbol${(absVal / 10000000).toStringAsFixed(1)}Cr';
      } else if (absVal >= 100000) {
        return '$symbol${(absVal / 100000).toStringAsFixed(1)}L';
      } else if (absVal >= 1000) {
        return '$symbol${(absVal / 1000).toStringAsFixed(1)}k';
      }
    }

    final hasDecimals = absVal % 1 != 0;
    final intPart = absVal.toInt().toString();
    final decimalPart = hasDecimals ? '.${absVal.toStringAsFixed(2).split('.')[1]}' : '';

    String formattedInt;
    if (intPart.length <= 3) {
      formattedInt = intPart;
    } else {
      // Last 3 digits
      final lastThree = intPart.substring(intPart.length - 3);
      final remaining = intPart.substring(0, intPart.length - 3);

      // Group preceding digits in pairs of 2
      final buffer = StringBuffer();
      for (int i = 0; i < remaining.length; i++) {
        final posFromEnd = remaining.length - i;
        buffer.write(remaining[i]);
        if (posFromEnd > 1 && posFromEnd % 2 == 1) {
          buffer.write(',');
        }
      }
      formattedInt = '${buffer.toString()},$lastThree';
    }

    final prefix = isNegative ? '-' : '';
    return '$prefix$symbol$formattedInt$decimalPart';
  }
}
