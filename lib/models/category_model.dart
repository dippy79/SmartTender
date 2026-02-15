class BusinessCategory {
  final String id;
  final String name;
  final String iconName;

  BusinessCategory({required this.id, required this.name, required this.iconName});

  // Supabase se data lene ke liye
  factory BusinessCategory.fromMap(Map<String, dynamic> map) {
    return BusinessCategory(
      id: map['id'],
      name: map['name'],
      iconName: map['icon_name'] ?? 'briefcase',
    );
  }
}