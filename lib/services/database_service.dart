import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/boq_item.dart';
import '../models/category_model.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  // 1. Dashboard Stats (Won, Lost, Total Value)
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final List<Map<String, dynamic>> tenders = await fetchTenders();
      double totalWonValue = 0;
      int wonCount = 0;
      int lostCount = 0;

      for (var t in tenders) {
        double base = (t['total_base'] as num).toDouble();
        double margin = (t['margin'] as num).toDouble();
        double freight = (t['freight'] as num).toDouble();
        double labour = (t['labour'] as num).toDouble();
        
        // Total Calculate: (Base + Freight + Labour) + Margin
        double directCost = base + freight + labour;
        double totalWithMargin = directCost + (directCost * (margin / 100));

        if (t['status'] == 'Won') {
          totalWonValue += totalWithMargin;
          wonCount++;
        } else if (t['status'] == 'Lost') {
          lostCount++;
        }
      }

      return {
        'totalValue': totalWonValue,
        'wonCount': wonCount,
        'lostCount': lostCount,
        'pendingCount': tenders.length - (wonCount + lostCount),
      };
    } catch (e) {
      return {'totalValue': 0.0, 'wonCount': 0, 'lostCount': 0, 'pendingCount': 0};
    }
  }

  // 2. Update Status (Won/Lost)
  Future<void> updateTenderStatus(String id, String status) async {
    try {
      await supabase.from('tenders').update({'status': status}).match({'id': id});
    } catch (e) {
      print("Update Status Error: $e");
    }
  }

  // 3. Save Tender
  Future<void> saveTender({
    required String businessType,
    required List<BOQItem> items,
    required double totalBase,
    required double margin,
    double freight = 0.0,
    double labour = 0.0,
  }) async {
    final List<Map<String, dynamic>> itemsJson = items.map((item) => {
      'name': item.name,
      'qty': item.quantity,
      'rate': item.baseRate,
    }).toList();

    try {
      await supabase.from('tenders').insert({
        'business_type': businessType,
        'items': itemsJson,
        'total_base': totalBase,
        'margin': margin,
        'freight': freight,
        'labour': labour,
        'status': 'Pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Save Error: $e");
    }
  }

  // 4. Fetch All Tenders
  Future<List<Map<String, dynamic>>> fetchTenders() async {
    try {
      final response = await supabase.from('tenders').select('*').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // 5. Smart AI Context Filter
  Future<String> getPastTendersSummary({int limit = 5, String year = 'All'}) async {
    try {
      final response = await fetchTenders();
      List<Map<String, dynamic>> tenders = List<Map<String, dynamic>>.from(response);
      if (year != 'All') tenders = tenders.where((t) => t['created_at'].toString().contains(year)).toList();
      tenders = tenders.take(limit).toList();
      if (tenders.isEmpty) return "No history found.";
      return tenders.map((t) => "Type: ${t['business_type']}, Margin: ${t['margin']}%").join(" | ");
    } catch (e) {
      return "History unavailable.";
    }
  }

  // 6. Categories CRUD
  Future<List<BusinessCategory>> fetchCategories() async {
    final response = await supabase.from('business_categories').select().order('name');
    return (response as List).map((map) => BusinessCategory.fromMap(map)).toList();
  }
  Future<void> addCategory(String name) async => await supabase.from('business_categories').insert({'name': name});
  Future<void> deleteCategory(String id) async => await supabase.from('business_categories').delete().match({'id': id});
  Future<void> deleteTender(String id) async => await supabase.from('tenders').delete().match({'id': id});
}