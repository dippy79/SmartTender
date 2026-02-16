import 'dart:math';

class AIService {
  // Yeh function tender details lega aur AI suggestion return karega
  Future<String> analyzeTender({
    required String category,
    required double totalAmount,
    required double margin,
    required String gst,
  }) async {
    // AI Thinking Simulation (2 seconds delay)
    await Future.delayed(const Duration(seconds: 2));

    // Smart Logic based on inputs
    if (margin < 10) {
      return "⚠️ AI Warning: Your margin ($margin%) is below industry standard for $category. It's risky but competitive.";
    } 
    
    if (totalAmount > 100000 && gst == "5%") {
      return "💡 AI Tip: For high-value $category tenders, double-check if 5% GST is applicable or if it falls under the 18% slab.";
    }

    List<String> generalInsights = [
      "✅ Analysis: This tender for $category looks solid. Profitability index is high.",
      "🚀 Strategy: Your pricing is optimal. High chances of winning this bid.",
      "📊 Market Data: Competitors usually quote 5% higher in the $category sector. You are in the safe zone."
    ];

    // Randomly pick an insight if no specific warning
    return generalInsights[Random().nextInt(generalInsights.length)];
  }
}