class BOQItem {
  final String id;
  final String name;
  final double quantity;
  final double baseRate;
  final double lastYearRate;

  BOQItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.baseRate,
    this.lastYearRate = 0.0,
  });

  double get totalBaseCost => quantity * baseRate;

  // Sensitivity Logic: Calculate % difference
  double get priceChangePercentage {
    if (lastYearRate == 0) return 0.0;
    return ((baseRate - lastYearRate) / lastYearRate) * 100;
  }
}