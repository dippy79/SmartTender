enum TenderType { government, private }

class Tender {
  final String id;
  final String organizationId; // Added for Multi-tenancy
  final String title;
  final String department;
  final double value;
  final DateTime deadline;
  final TenderType type;
  final String category;
  final String? link;

  Tender({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.department,
    required this.value,
    required this.deadline,
    required this.type,
    required this.category,
    this.link,
  });

  factory Tender.fromJson(Map<String, dynamic> json) {
    return Tender(
      id: json['id'].toString(),
      organizationId: json['organization_id'] ?? '',
      title: json['title'] ?? 'Untitled',
      department: json['department'] ?? 'N/A',
      value: (json['value'] ?? 0).toDouble(),
      deadline: DateTime.tryParse(json['deadline'] ?? "") ?? DateTime.now(),
      type: json['is_private'] == true ? TenderType.private : TenderType.government,
      category: json['category'] ?? 'General',
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'title': title,
      'department': department,
      'value': value,
      'deadline': deadline.toIso8601String(),
      'is_private': type == TenderType.private,
      'category': category,
      'link': link,
    };
  }
}
