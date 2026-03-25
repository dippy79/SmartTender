class BoqItem {
  String id;
  String name;
  String category;
  double quantity;
  String unit;
  double baseRate;
  double gstPercent;

  BoqItem({
    String? id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.baseRate,
    this.gstPercent = 18.0,
  }) : id = id ?? '';

  double get amount => quantity * baseRate;
  double get gstAmount => amount * gstPercent / 100;
  double get total => amount + gstAmount;

  Map<String, dynamic> toMap({String? submissionId}) {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'rate': baseRate,
      'gst_percent': gstPercent,
      'amount': amount,
      'gst_amount': gstAmount,
      'total': total,
      'submission_id': submissionId,
    };
  }

  factory BoqItem.fromMap(Map<String, dynamic> map) {
    return BoqItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      baseRate: (map['rate'] as num).toDouble(),
      gstPercent: (map['gst_percent'] as num?)?.toDouble() ?? 18.0,
    );
  }

  BoqItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? baseRate,
    double? gstPercent,
  }) {
    return BoqItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      baseRate: baseRate ?? this.baseRate,
      gstPercent: gstPercent ?? this.gstPercent,
    );
  }
}
