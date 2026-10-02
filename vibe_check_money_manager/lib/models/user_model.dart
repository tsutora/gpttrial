import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class WalletMood {
  final String id;
  final String userId;
  final int moodScore; // 0-100
  final String moodEmoji;
  final String moodMessage;
  final DateTime calculatedAt;
  final double dailySpending;
  final double dailyIncome;
  final double budgetHealth; // 0-100

  WalletMood({
    required this.id,
    required this.userId,
    required this.moodScore,
    required this.moodEmoji,
    required this.moodMessage,
    required this.calculatedAt,
    required this.dailySpending,
    required this.dailyIncome,
    required this.budgetHealth,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'moodScore': moodScore,
      'moodEmoji': moodEmoji,
      'moodMessage': moodMessage,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
      'dailySpending': dailySpending,
      'dailyIncome': dailyIncome,
      'budgetHealth': budgetHealth,
    };
  }

  factory WalletMood.fromJson(Map<String, dynamic> json) {
    return WalletMood(
      id: json['id'] as String,
      userId: json['userId'] as String,
      moodScore: json['moodScore'] as int,
      moodEmoji: json['moodEmoji'] as String,
      moodMessage: json['moodMessage'] as String,
      calculatedAt: (json['calculatedAt'] as Timestamp).toDate(),
      dailySpending: (json['dailySpending'] as num).toDouble(),
      dailyIncome: (json['dailyIncome'] as num).toDouble(),
      budgetHealth: (json['budgetHealth'] as num).toDouble(),
    );
  }
}
