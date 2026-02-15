import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';

class AIService {
  static Future<String> getSmartAdvice({
    required String userMessage, 
    required String currentData,
    required String historyData,
  }) async {
    // Check if AI is configured
    if (!AppConfig.isAiConfigured) {
      return "AI features not configured. Please set GEMINI_API_KEY in environment variables.";
    }
    
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: AppConfig.geminiApiKey);
      
      final prompt = """
      You are a Smart Tender Expert. 
      CONTEXT:
      1. Current Project: $currentData
      2. User's Past Tenders: $historyData
      
      TASK:
      Analyze the current tender based on the user's history. 
      If the current margin is much higher/lower than their usual, warn them.
      If the business type is new, give tips for that specific industry.
      Reply in professional Hinglish. Keep it under 100 words.
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? "Main abhi iska jawab nahi de pa raha hoon.";
    } catch (e) {
      return "AI connection error. Please check your API key.";
    }
  }
}