import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tender_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;
  String? _currentOrgId;

  Future<String?> getOrganizationId() async {
    if (_currentOrgId != null) return _currentOrgId;
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client.from('user_profiles').select('organization_id').eq('id', userId).maybeSingle();
    if (response != null) _currentOrgId = response['organization_id'];
    return _currentOrgId;
  }

  // Parameter renamed to isAdmin for dashboard compatibility
  Stream<List<Tender>> getTenderStream({String? category, bool isAdmin = false}) async* {
    final orgId = await getOrganizationId();
    if (orgId == null && !isAdmin) {
      yield [];
      return;
    }

    yield* _client.from('tenders').stream(primaryKey: ['id']).map((data) {
      var list = data.map((json) => Tender.fromJson(json)).toList();
      if (!isAdmin) list = list.where((t) => t.organizationId == orgId).toList();
      if (category != null && category != 'All') {
        list = list.where((t) => t.category == category).toList();
      }
      return list;
    });
  }

  Future<String> createOrganization(String name) async {
    final response = await _client.from('organizations').insert({'name': name}).select('id').single();
    return response['id'];
  }

  // Made orgId optional with a default or handling
  Future<void> updatePreferences(String userId, String businessType, String category, [String? orgId]) async {
    final data = {
      'id': userId,
      'business_type': businessType,
      'preferred_category': category,
    };
    if (orgId != null) data['organization_id'] = orgId;
    await _client.from('user_profiles').upsert(data);
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _client.from('user_roles').stream(primaryKey: ['id']);
  }

  Future<void> toggleUserBlock(String userId, bool isBlocked) async {
    await _client.from('user_roles').update({'is_blocked': isBlocked}).eq('id', userId);
  }

  String? get currentUserId => _client.auth.currentUser?.id;
}
