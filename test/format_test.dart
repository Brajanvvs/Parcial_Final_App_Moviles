import 'package:flutter_test/flutter_test.dart';
import 'package:taller_final/core/format.dart';

void main() {
  test('formatMoney uses Colombian thousands separator', () {
    expect(formatMoney(39900), r'$39.900');
    expect(formatMoney(0), r'$0');
    expect(formatMoney(12000), r'$12.000');
    expect(formatMoney(1000000), r'$1.000.000');
  });

  test('formatPercent reads tax rates as fractions', () {
    expect(formatPercent(0.19), '19%');
    expect(formatPercent(19), '19%');
  });
}
