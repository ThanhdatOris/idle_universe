import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idle_universe/core/utils/number_formatter.dart';

void main() {
  group('NumberFormatter - Suffix Format Tests', () {
    test('Format dưới 1000 - hiển thị số nguyên', () {
      expect(NumberFormatter.format(Decimal.fromInt(0)), '0');
      expect(NumberFormatter.format(Decimal.fromInt(123)), '123');
      expect(NumberFormatter.format(Decimal.fromInt(999)), '999');
    });

    test('Format K (Thousand)', () {
      expect(NumberFormatter.format(Decimal.fromInt(1000)), '1.00K');
      expect(NumberFormatter.format(Decimal.fromInt(1234)), '1.23K');
      expect(NumberFormatter.format(Decimal.fromInt(999999)), '1000.00K');
    });

    test('Format M (Million)', () {
      expect(NumberFormatter.format(Decimal.fromInt(1000000)), '1.00M');
      expect(NumberFormatter.format(Decimal.fromInt(1234567)), '1.23M');
    });

    test('Format B (Billion)', () {
      expect(NumberFormatter.format(Decimal.fromInt(1000000000)), '1.00B');
      expect(NumberFormatter.format(Decimal.parse('1234567890')), '1.23B');
    });

    test('Format T (Trillion)', () {
      expect(NumberFormatter.format(Decimal.parse('1000000000000')), '1.00T');
      expect(NumberFormatter.format(Decimal.parse('5678900000000')), '5.68T');
    });

    test('Format Qa (Quadrillion)', () {
      expect(NumberFormatter.format(Decimal.parse('1000000000000000')), '1.00Qa');
    });

    test('Format Qi (Quintillion)', () {
      expect(NumberFormatter.format(Decimal.parse('1000000000000000000')), '1.00Qi');
    });

    test('Format Dc (Decillion) - suffix cuối cùng', () {
      expect(NumberFormatter.format(Decimal.parse('1000000000000000000000000000000000')), '1.00Dc');
      expect(NumberFormatter.format(Decimal.parse('5670000000000000000000000000000000')), '5.67Dc');
    });
  });

  group('NumberFormatter - Scientific Notation Tests', () {
    test('Sau Dc chuyển sang scientific notation', () {
      // 10^36 = 1000 Dc → chuyển sang 1.00e36
      final value = Decimal.parse('1000000000000000000000000000000000000'); // 10^36
      final result = NumberFormatter.format(value);
      expect(result, contains('e'));
      expect(result, '1.00e36');
    });

    test('Số cực lớn dùng scientific notation', () {
      // 10^100
      final value = Decimal.parse('10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000');
      final result = NumberFormatter.format(value);
      expect(result, '1.00e100');
    });

    test('Scientific notation với decimal', () {
      // 1.23 * 10^50
      final value = Decimal.parse('123000000000000000000000000000000000000000000000000'); // 1.23e50
      final result = NumberFormatter.format(value);
      expect(result, contains('e'));
    });
  });

  group('NumberFormatter - Parse Tests', () {
    test('Parse suffixes', () {
      expect(NumberFormatter.parse('1K'), Decimal.fromInt(1000));
      expect(NumberFormatter.parse('1.5K'), Decimal.parse('1500'));
      expect(NumberFormatter.parse('2M'), Decimal.fromInt(2000000));
      expect(NumberFormatter.parse('3.5B'), Decimal.parse('3500000000'));
    });

    test('Parse scientific notation', () {
      expect(NumberFormatter.parse('1e3'), Decimal.fromInt(1000));
      expect(NumberFormatter.parse('1.5e6'), Decimal.parse('1500000'));
      expect(NumberFormatter.parse('2.5E9'), Decimal.parse('2500000000'));
    });

    test('Parse số thường', () {
      expect(NumberFormatter.parse('123'), Decimal.fromInt(123));
      expect(NumberFormatter.parse('1234.56'), Decimal.parse('1234.56'));
    });

    test('Parse invalid input', () {
      expect(NumberFormatter.parse(''), null);
      expect(NumberFormatter.parse('abc'), null);
      expect(NumberFormatter.parse('1X'), null); // X không phải suffix hợp lệ
    });
  });

  group('NumberFormatter - Edge Cases', () {
    test('Xử lý số âm', () {
      expect(NumberFormatter.format(Decimal.fromInt(-1234)), '-1.23K');
      expect(NumberFormatter.format(Decimal.fromInt(-1000000)), '-1.00M');
    });

    test('Custom decimals', () {
      expect(NumberFormatter.format(Decimal.fromInt(1234), decimals: 0), '1K');
      expect(NumberFormatter.format(Decimal.fromInt(1234), decimals: 3), '1.234K');
    });

    test('FormatCost - division by zero protection', () {
      final result = NumberFormatter.formatCost(
        Decimal.zero,
        Decimal.fromInt(100),
      );
      expect(result['percentage'], 1.0); // Không bị infinity
    });
  });

  group('NumberFormatter - Utility Tests', () {
    test('formatWithSuffix', () {
      expect(
        NumberFormatter.formatWithSuffix(Decimal.fromInt(1234), 'Energy/s'),
        '1.23K Energy/s',
      );
    });

    test('formatTime', () {
      expect(NumberFormatter.formatTime(45), '45s');
      expect(NumberFormatter.formatTime(90), '1m 30s');
      expect(NumberFormatter.formatTime(3661), '1h 1m 1s');
    });

    test('formatPercentage', () {
      expect(NumberFormatter.formatPercentage(0.5), '50.0%');
      expect(NumberFormatter.formatPercentage(0.123), '12.3%');
      expect(NumberFormatter.formatPercentage(1.0), '100.0%');
    });

    test('formatCost', () {
      final result = NumberFormatter.formatCost(
        Decimal.fromInt(1000),
        Decimal.fromInt(500),
      );
      expect(result['text'], '1.00K');
      expect(result['canAfford'], false);
      expect(result['percentage'], 0.5);
    });
  });
}
