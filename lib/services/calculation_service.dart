class CalculationService {
  // 1. Sirf Materials ki Base Cost nikalna
  static double calculateTotalBase(List items) {
    return items.fold(0, (sum, item) => sum + item.totalBaseCost);
  }

  // 2. Business Type ke hisab se Extra Overhead (Taxes/Insurance etc)
  static double getBusinessExtraCost(String type, double amount) {
    switch (type.toLowerCase()) {
      case 'construction':
        return amount * 0.05; // 5% Extra for safety/permits
      case 'electrical':
        return amount * 0.03; // 3% Extra for tools/testing
      default:
        return amount * 0.02; // 2% Default
    }
  }

  // 3. Final Breakdown Calculation
  static Map<String, double> getFullBreakdown({
    required double materialBase,
    required double freight,
    required double labour,
    required double marginPercent,
    required double gstPercent,
    required bool isGstEnabled,
  }) {
    double directCost = materialBase + freight + labour;
    double extraOverhead = directCost * 0.02; // Chhota mota kharcha
    
    double costBeforeMargin = directCost + extraOverhead;
    double profitAmount = costBeforeMargin * (marginPercent / 100);
    
    double taxableValue = costBeforeMargin + profitAmount;
    double gstTotal = isGstEnabled ? (taxableValue * (gstPercent / 100)) : 0;
    
    return {
      'taxableValue': taxableValue,
      'cgst': gstTotal / 2,
      'sgst': gstTotal / 2,
      'totalQuote': taxableValue + gstTotal,
      'profit': profitAmount,
    };
  }
}