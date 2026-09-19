import 'package:flutter_test/flutter_test.dart';
import 'package:chelav_app/core/utils/currency_formatter.dart';

void main() {
  test('CurrencyFormatter formats Indian Rupees accurately', () {
    expect(CurrencyFormatter.format(1250), '₹1,250');
    expect(CurrencyFormatter.format(25000), '₹25,000');
    expect(CurrencyFormatter.format(105500), '₹1,05,500');
    expect(CurrencyFormatter.format(5000000), '₹50,00,000');
    expect(CurrencyFormatter.format(-1500), '-₹1,500');
  });
}
