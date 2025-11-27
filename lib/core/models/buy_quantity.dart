/// BuyQuantity - Enum for bulk buying options
enum BuyQuantity {
  one(1, 'x1'),
  ten(10, 'x10'),
  twentyFive(25, 'x25'),
  hundred(100, 'x100'),
  max(-1, 'MAX');

  final int value;
  final String label;

  const BuyQuantity(this.value, this.label);

  /// Check if this is the MAX option
  bool get isMax => this == BuyQuantity.max;

  /// Get next buy quantity in cycle
  BuyQuantity get next {
    switch (this) {
      case BuyQuantity.one:
        return BuyQuantity.ten;
      case BuyQuantity.ten:
        return BuyQuantity.twentyFive;
      case BuyQuantity.twentyFive:
        return BuyQuantity.hundred;
      case BuyQuantity.hundred:
        return BuyQuantity.max;
      case BuyQuantity.max:
        return BuyQuantity.one;
    }
  }
}
