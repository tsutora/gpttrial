import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/transactions_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String selectedPeriod = 'month';

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsStreamProvider);

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'analytics board 📊',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['week', 'month', 'year'].map((period) {
                      bool isSelected = selectedPeriod == period;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedPeriod = period),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              period,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Category Breakdown
                transactions.when(
                  data: (txns) {
                    final filteredTxns = _filterTransactionsByPeriod(txns, selectedPeriod);
                    final categoryCounts = _getCategoryBreakdown(filteredTxns);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'where\'s your money going?',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: categoryCounts.entries.map((entry) {
                              final percentage = entry.value['percentage'] as double;
                              final amount = entry.value['amount'] as double;
                              final emoji = entry.value['emoji'] as String;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(emoji, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Rp ${amount.toStringAsFixed(0)}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(0)}%',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => Text('Error: $error'),
                ),
                const SizedBox(height: 24),

                // Insights
                transactions.when(
                  data: (txns) {
                    final filteredTxns = _filterTransactionsByPeriod(txns, selectedPeriod);
                    final insights = _generateInsights(filteredTxns);

                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'your vibe insights 💡',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...insights.map((insight) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                insight,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => Text('Error: $error'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<dynamic> _filterTransactionsByPeriod(List<dynamic> txns, String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default: // month
        startDate = DateTime(now.year, now.month, 1);
    }

    return txns.where((txn) => txn.date.isAfter(startDate) && !txn.isIncome).toList();
  }

  Map<String, dynamic> _getCategoryBreakdown(List<dynamic> txns) {
    final breakdown = <String, dynamic>{};
    final total = txns.fold<double>(0, (sum, txn) => sum + txn.amount);

    for (var txn in txns) {
      if (!breakdown.containsKey(txn.category)) {
        breakdown[txn.category] = {
          'amount': 0.0,
          'emoji': txn.categoryEmoji,
        };
      }
      breakdown[txn.category]['amount'] += txn.amount;
    }

    // Add percentages
    breakdown.forEach((key, value) {
      value['percentage'] = total > 0 ? (value['amount'] / total) * 100 : 0;
    });

    // Sort by amount
    final sorted = Map.fromEntries(
      breakdown.entries.toList()..sort((a, b) => (b.value['amount'] as double).compareTo(a.value['amount'] as double)),
    );

    return sorted;
  }

  List<String> _generateInsights(List<dynamic> txns) {
    final insights = <String>[];

    if (txns.isEmpty) {
      return ['no data for this period yet. add some transactions! 📊'];
    }

    final total = txns.fold<double>(0, (sum, txn) => sum + txn.amount);
    final avgTransaction = total / txns.length;

    insights.add('• you spent Rp ${total.toStringAsFixed(0)} this ${selectedPeriod}.');

    if (avgTransaction > 500000) {
      insights.add('• your average transaction is high (Rp ${avgTransaction.toStringAsFixed(0)}). consider consolidating purchases? 🤔');
    } else if (avgTransaction < 100000) {
      insights.add('• your transactions are small & frequent. maybe bulk buying could help? 🛒');
    }

    // Most spent category
    final categories = <String, double>{};
    for (var txn in txns) {
      categories[txn.category] = (categories[txn.category] ?? 0) + txn.amount;
    }

    if (categories.isNotEmpty) {
      final topCategory = categories.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('• your biggest spending: ${topCategory.key} (Rp ${topCategory.value.toStringAsFixed(0)}). 💸');
    }

    insights.add('• keep the vibe going! consistent tracking = better insights 📈');

    return insights;
  }
}
