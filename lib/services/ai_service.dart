import 'dart:math';

class AIService {
  // Analyze tender and provide smart suggestions
  Future<String> analyzeTender({
    required String category,
    required double totalAmount,
    required double margin,
    required String gst,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // simulate AI thinking

    if (margin < 10) {
      return "⚠️ AI Warning: Your margin ($margin%) is below industry standard for $category. Risky but competitive.";
    }

    if (totalAmount > 100000 && gst == "5%") {
      return "💡 AI Tip: High-value $category tenders with 5% GST. Check if 18% applies.";
    }

    List<String> generalInsights = [
      "✅ Analysis: Tender for $category looks solid. Profitability index high.",
      "🚀 Strategy: Pricing is optimal. High chances of winning this bid.",
      "📊 Market Data: Competitors usually quote 5% higher. You are safe."
    ];

    return generalInsights[Random().nextInt(generalInsights.length)];
  }
}
