import '../models/boq_item.dart';
import 'supabase_client.dart';

class BoqRepository {
  // Save BOQ to boq_submissions table
  static Future<String> saveBoq(BoqSubmission submission) async {
    final supabase = SupabaseClientHelper.client;
    final data = await supabase
      .from('boq_submissions')
      .insert(submission.toMap())
      .select('id')
      .single();
    return data['id'] as String;
  }

  // Save BOQ items to boq_items table
  static Future<void> saveItems(String submissionId, List<BoqItem> items) async {
    final supabase = SupabaseClientHelper.client;
    final itemMaps = items.map((i) => {
      ...i.toMap(submissionId: submissionId),
    }).toList();
    await supabase.from('boq_items').insert(itemMaps);
  }

  // Fetch item library (library items not belonging to submissions)
  static Future<List<BoqItem>> fetchItemLibrary(String category) async {
    final supabase = SupabaseClientHelper.client;
    final data = await supabase
      .from('boq_items')
      .select()
      .eq('category', category)
      .not('submission_id', 'is.null', false)
      .order('name');
    return (data as List).map((r) => BoqItem.fromMap(r)).toList();
  }
}

class BoqSubmission {
  final String id;
  final String projectName;
  final String location;
  final String category;
  final String? tenderId;
  final DateTime deadline;
  final double marginPercent;
  final double globalGst;
  final double lowBid;
  final double midBid;
  final double maxBid;
  final DateTime createdAt;
  final String status;

  const BoqSubmission({
    required this.id,
    required this.projectName,
    required this.location,
    required this.category,
    this.tenderId,
    required this.deadline,
    required this.marginPercent,
    required this.globalGst,
    required this.lowBid,
    required this.midBid,
    required this.maxBid,
    required this.createdAt,
    this.status = 'Draft',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_name': projectName,
      'location': location,
      'category': category,
      'tender_id': tenderId,
      'deadline': deadline.toIso8601String(),
      'margin_percent': marginPercent,
      'global_gst': globalGst,
      'bid_value_low': lowBid,
      'bid_value_mid': midBid,
      'bid_value_max': maxBid,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'user_id': SupabaseClientHelper.client.auth.currentUser?.id,
    };
  }

  factory BoqSubmission.fromMap(Map<String, dynamic> map) {
    return BoqSubmission(
      id: map['id'] as String,
      projectName: map['project_name'] as String,
      location: map['location'] as String,
      category: map['category'] as String,
      tenderId: map['tender_id'] as String?,
      deadline: DateTime.parse(map['deadline'] as String),
      marginPercent: (map['margin_percent'] as num).toDouble(),
      globalGst: (map['global_gst'] as num).toDouble(),
      lowBid: (map['bid_value_low'] as num).toDouble(),
      midBid: (map['bid_value_mid'] as num).toDouble(),
      maxBid: (map['bid_value_max'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      status: map['status'] as String? ?? 'Draft',
    );
  }
}
