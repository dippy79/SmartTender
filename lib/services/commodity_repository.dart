import '../models/commodity_rate.dart';
import 'supabase_client.dart';

class CommodityRepository {
  // Fetch all commodity rates filtered by business type
  static Future<List<CommodityRate>> fetchRates({String? businessType}) async {
    final supabase = SupabaseClientHelper.client;
    List<dynamic> data;
    
    if (businessType != null && businessType != 'General') {
      data = await supabase
        .from('commodity_rates')
        .select('id, name, unit, current_price, previous_price, change_percent, category, updated_at')
        .eq('category', businessType)
        .order('name', ascending: true);
    } else {
      data = await supabase
        .from('commodity_rates')
        .select('id, name, unit, current_price, previous_price, change_percent, category, updated_at')
        .order('name', ascending: true);
    }
    
    return data.map((r) => CommodityRate.fromMap(r as Map<String, dynamic>)).toList();
  }

  // Fetch 7-day history for trend chart
  static Future<List<PricePoint>> fetchHistory(String commodityId) async {
    final supabase = SupabaseClientHelper.client;
    final data = await supabase
      .from('commodity_rates')
      .select('current_price, updated_at')
      .eq('id', commodityId)
      .order('updated_at', ascending: false)
      .limit(7);
    return (data as List).map((r) => PricePoint.fromMap(r)).toList();
  }
}
