import 'package:decimal/decimal.dart';

/// Number formatter utilities - Format số lớn cho idle game
/// Hỗ trợ: 1K, 1M, 1B, 1T, scientific notation (1e6)
class NumberFormatter {
  /// Helper: Convert Rational to Decimal (vì Decimal * Decimal trả về Rational)
  static Decimal _toDecimal(dynamic value) {
    if (value is Decimal) return value;
    // Rational → double → Decimal (precision có thể bị mất nhưng đủ dùng)
    return Decimal.parse(value.toDouble().toString());
  }
  /// Format Decimal thành string dễ đọc (1.23K, 4.56M, 7.89B...)
  /// 
  /// Ví dụ:
  /// - 999 → "999"
  /// - 1234 → "1.23K"
  /// - 1234567 → "1.23M"
  /// - 1234567890 → "1.23B"
  /// - 10^36+ → "1.23e36" (scientific notation)
  static String format(Decimal value, {int decimals = 2}) {
    // Xử lý số âm
    if (value < Decimal.zero) {
      return '-${format(value.abs(), decimals: decimals)}';
    }

    if (value < Decimal.fromInt(1000)) {
      // Dưới 1000: hiển thị số nguyên
      return value.toStringAsFixed(0);
    }

    // Danh sách suffixes đến Dc (Decillion = 10^33)
    const suffixes = [
      '', 'K', 'M', 'B', 'T', // 10^0, 10^3, 10^6, 10^9, 10^12
      'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc', // 10^15, 10^18, 10^21, 10^24, 10^27, 10^30, 10^33
    ];

    int suffixIndex = 0;
    Decimal tempValue = value;
    final thousand = Decimal.fromInt(1000);

    // Chia cho 1000 đến khi < 1000 hoặc hết suffix
    while (tempValue >= thousand && suffixIndex < suffixes.length - 1) {
      tempValue = _toDecimal(tempValue / thousand);
      suffixIndex++;
    }

    // Nếu đã đến Dc và vẫn >= 1000 → chuyển sang scientific notation
    if (suffixIndex == suffixes.length - 1 && tempValue >= thousand) {
      return _toScientificNotation(value, decimals: decimals);
    }

    // Format với decimals
    final formattedNumber = tempValue.toStringAsFixed(decimals);
    return '$formattedNumber${suffixes[suffixIndex]}';
  }

  /// Format thành scientific notation (1.23e36)
  /// Giữ nguyên precision của Decimal, không chuyển sang double
  static String _toScientificNotation(Decimal value, {int decimals = 2}) {
    if (value == Decimal.zero) return '0';

    // Tính exponent: log10(value)
    int exponent = 0;
    Decimal mantissa = value;
    final ten = Decimal.fromInt(10);

    // Normalize: đưa mantissa về [1, 10)
    if (mantissa >= ten) {
      while (mantissa >= ten) {
        mantissa = _toDecimal(mantissa / ten);
        exponent++;
      }
    } else if (mantissa < Decimal.one) {
      while (mantissa < Decimal.one) {
        mantissa = _toDecimal(mantissa * ten);
        exponent--;
      }
    }

    // Format: 1.23e36
    final formattedMantissa = mantissa.toStringAsFixed(decimals);
    return '${formattedMantissa}e$exponent';
  }

  /// Format với suffix cụ thể (ví dụ: "1.23 Energy/s")
  static String formatWithSuffix(Decimal value, String suffix, {int decimals = 2}) {
    return '${format(value, decimals: decimals)} $suffix';
  }

  /// Format thời gian (giây → h:m:s)
  static String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Format percentage (0.5 → "50%")
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Parse string về Decimal (hỗ trợ suffixes: "1.5K" → 1500, "1.5e6" → 1500000)
  static Decimal? parse(String input) {
    if (input.isEmpty) return null;

    final trimmed = input.trim();

    // Kiểm tra scientific notation (1.5e6, 2.3E12)
    final scientificRegex = RegExp(r'^(-?\d+\.?\d*)[eE]([+-]?\d+)$');
    final scientificMatch = scientificRegex.firstMatch(trimmed);
    
    if (scientificMatch != null) {
      try {
        final mantissa = Decimal.parse(scientificMatch.group(1)!);
        final exponent = int.parse(scientificMatch.group(2)!);
        final ten = Decimal.fromInt(10);
        
        // Tính 10^exponent
        Decimal multiplier = Decimal.one;
        if (exponent > 0) {
          for (int i = 0; i < exponent; i++) {
            multiplier = _toDecimal(multiplier * ten);
          }
        } else if (exponent < 0) {
          for (int i = 0; i > exponent; i--) {
            multiplier = _toDecimal(multiplier / ten);
          }
        }
        
        return _toDecimal(mantissa * multiplier);
      } catch (e) {
        return null;
      }
    }

    // Map suffixes sang multipliers (dùng Decimal để tránh overflow)
    final suffixMap = <String, Decimal>{
      'K': Decimal.fromInt(1000),                           // 10^3
      'M': Decimal.fromInt(1000000),                        // 10^6
      'B': Decimal.fromInt(1000000000),                     // 10^9
      'T': Decimal.parse('1000000000000'),                  // 10^12
      'QA': Decimal.parse('1000000000000000'),              // 10^15
      'QI': Decimal.parse('1000000000000000000'),           // 10^18
      'SX': Decimal.parse('1000000000000000000000'),        // 10^21
      'SP': Decimal.parse('1000000000000000000000000'),     // 10^24
      'OC': Decimal.parse('1000000000000000000000000000'),  // 10^27
      'NO': Decimal.parse('1000000000000000000000000000000'), // 10^30
      'DC': Decimal.parse('1000000000000000000000000000000000'), // 10^33
    };

    // Tìm suffix cuối cùng
    final suffixRegex = RegExp(r'([A-Z]{1,2})$', caseSensitive: false);
    final match = suffixRegex.firstMatch(trimmed);

    if (match != null) {
      final suffix = match.group(1)!.toUpperCase();
      final numberPart = trimmed.substring(0, match.start).trim();
      
      try {
        final number = Decimal.parse(numberPart);
        final multiplier = suffixMap[suffix];
        if (multiplier == null) return null;
        return number * multiplier;
      } catch (e) {
        return null;
      }
    }

    // Không có suffix, parse trực tiếp
    try {
      return Decimal.parse(trimmed);
    } catch (e) {
      return null;
    }
  }

  /// Format cost (với màu/icon - dùng trong UI)
  /// Trả về Map để dễ xử lý trong widget
  static Map<String, dynamic> formatCost(Decimal cost, Decimal currentAmount) {
    return {
      'text': format(cost),
      'canAfford': currentAmount >= cost,
      'percentage': cost > Decimal.zero ? (currentAmount / cost).toDouble() : 1.0, // 0.0 - 1.0+
    };
  }
}
