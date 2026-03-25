import '../models/tender.dart';
import 'supabase_client.dart';

class TenderRepository {
  static Future<List<Tender>> fetchTenders({
    required String type,
    String searchQuery = '',
    String? category,
    String? status,
    bool bookmarkedOnly = false,
    int page = 0,
    int pageSize = 20,
  }) async {
    final supabase = SupabaseClientHelper.client;
    var query = supabase
      .from('tenders')
      .select('id, title, department, location, value, deadline, status, category, created_at, is_bookmarked, type')
      .eq('type', type);

    if (searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }
    if (status != null && status != 'All') {
      query = query.eq('status', status);
    }
    if (bookmarkedOnly) {
      query = query.eq('is_bookmarked', true);
    }

    final data = await query
      .order('deadline', ascending: true)
      .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((r) => Tender.fromMap(r)).toList();
  }

  static Future<void> toggleBookmark(String tenderId, bool current) async {
    final supabase = SupabaseClientHelper.client;
    await supabase
      .from('tenders')
      .update({'is_bookmarked': !current})
      .eq('id', tenderId);
  }
}
