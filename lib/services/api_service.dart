import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = 'sb_publishable_sRMu7lj4qZwIHxiiXAHLlA_UctBrKQy';
  final String baseUrl = 'https://commodities-api.com/api/latest';

  Future<Map<String, dynamic>> fetchLiveRates() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl?access_key=$apiKey&base=USD&symbols=STEEL,IRON,XAU'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'rates': data['data']['rates'],
          'unit': 'USD'
        };
      } else {
        return {'success': false, 'error': 'Server Error'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
