class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.dateTime,
    this.notes,
    this.receiptImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime dateTime;
  final String? notes;
  final String? receiptImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense copyWith({
    String? title,
    double? amount,
    String? categoryId,
    DateTime? dateTime,
    String? notes,
    String? receiptImagePath,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'categoryId': categoryId,
        'dateTime': dateTime.toIso8601String(),
        'notes': notes,
        'receiptImagePath': receiptImagePath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static Expense fromJson(Map<String, Object?> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      notes: json['notes'] as String?,
      receiptImagePath: json['receiptImagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

