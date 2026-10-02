import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String label;
  final String category;
  final String categoryEmoji;
  final bool isIncome;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.label,
    required this.category,
    required this.categoryEmoji,
    required this.isIncome,
    required this.date,
    this.note,
    required this.createdAt,
  });

  // Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'label': label,
      'category': category,
      'categoryEmoji': categoryEmoji,
      'isIncome': isIncome,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      label: json['label'] as String,
      category: json['category'] as String,
      categoryEmoji: json['categoryEmoji'] as String,
      isIncome: json['isIncome'] as bool,
      date: (json['date'] as Timestamp).toDate(),
      note: json['note'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method
  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? label,
    String? category,
    String? categoryEmoji,
    bool? isIncome,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      label: label ?? this.label,
      category: category ?? this.category,
      categoryEmoji: categoryEmoji ?? this.categoryEmoji,
      isIncome: isIncome ?? this.isIncome,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
