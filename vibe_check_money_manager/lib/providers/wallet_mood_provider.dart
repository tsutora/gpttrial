import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'transactions_provider.dart';

// Wallet mood provider
final walletMoodProvider = FutureProvider.autoDispose<WalletMood>((ref) async {
  final transactions = await ref.watch(transactionsStreamProvider.future);
  final auth = ref.watch(authStateProvider);

  if (auth.value == null) {
    return _getDefaultMood('No User');
  }

  final userId = auth.value!.uid;
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  // Get today's transactions
  final todayTransactions = transactions
      .where((t) => t.date.isAfter(todayStart) && t.date.isBefore(today.add(const Duration(days: 1))))
      .toList();

  // Calculate metrics
  final totalSpending = todayTransactions
      .where((t) => !t.isIncome)
      .fold<double>(0, (sum, t) => sum + t.amount);

  final totalIncome = todayTransactions
      .where((t) => t.isIncome)
      .fold<double>(0, (sum, t) => sum + t.amount);

  // Get weekly baseline for comparison
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final weekTransactions = transactions
      .where((t) => !t.isIncome && t.date.isAfter(weekStart.subtract(const Duration(days: 1))))
      .toList();

  final avgDailySpending = weekTransactions.isEmpty
      ? 0.0
      : weekTransactions.fold<double>(0, (sum, t) => sum + t.amount) / 7;

  // Calculate mood score (0-100)
  final moodScore = _calculateMoodScore(
    dailySpending: totalSpending,
    dailyIncome: totalIncome,
    avgDailySpending: avgDailySpending,
  );

  // Get mood emoji and message
  final (moodEmoji, moodMessage) = _getMoodEmojiAndMessage(moodScore);

  // Calculate budget health (simplified)
  final budgetHealth = ((totalIncome - totalSpending) / (totalIncome + 1) * 100).clamp(0, 100);

  return WalletMood(
    id: 'mood-$userId-${today.toIso8601String().split('T')[0]}',
    userId: userId,
    moodScore: moodScore,
    moodEmoji: moodEmoji,
    moodMessage: moodMessage,
    calculatedAt: today,
    dailySpending: totalSpending,
    dailyIncome: totalIncome,
    budgetHealth: budgetHealth.toDouble(),
  );
});

int _calculateMoodScore({
  required double dailySpending,
  required double dailyIncome,
  required double avgDailySpending,
}) {
  double score = 50; // Base score

  // Spending comparison (-/+ based on baseline)
  if (avgDailySpending > 0) {
    final spendingRatio = dailySpending / avgDailySpending;
    if (spendingRatio > 1.3) {
      score -= (spendingRatio - 1.3) * 20;
    } else if (spendingRatio < 0.7) {
      score += (0.7 - spendingRatio) * 15;
    }
  }

  // Income bonus
  if (dailyIncome > 0) {
    score += (dailyIncome / 500000 * 15).clamp(0, 25).toDouble();
  }

  // Balance bonus
  if (dailySpending <= dailyIncome) {
    score += 15;
  }

  return score.clamp(0, 100).toInt();
}

(String emoji, String message) _getMoodEmojiAndMessage(int score) {
  if (score >= 90) {
    return ('🍽️', 'we feasting');
  } else if (score >= 75) {
    return ('💪', 'saving arc');
  } else if (score >= 60) {
    return ('🎵', 'vibing');
  } else if (score >= 40) {
    return ('🎉', 'treat yourself energy');
  } else if (score >= 20) {
    return ('⚠️', 'financial check needed');
  } else {
    return ('😰', 'big oof');
  }
}

WalletMood _getDefaultMood(String error) {
  return WalletMood(
    id: 'default-mood',
    userId: 'unknown',
    moodScore: 0,
    moodEmoji: '?',
    moodMessage: error,
    calculatedAt: DateTime.now(),
    dailySpending: 0,
    dailyIncome: 0,
    budgetHealth: 0,
  );
}
