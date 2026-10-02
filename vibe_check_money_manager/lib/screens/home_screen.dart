import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/wallet_mood_provider.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsStreamProvider);
    final walletMood = ref.watch(walletMoodProvider);

    return Scaffold(
      body: SafeArea(
        child: _selectedIndex == 0
            ? CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'yo, wadup! 👋',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'your financial glow-up awaits ✨',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
                          // AI Wallet Mood Card
                          walletMood.when(
                            data: (mood) => _MoodCard(mood: mood),
                            loading: () => _MoodCardSkeleton(),
                            error: (error, stackTrace) => Text('Error: $error'),
                          ),
                          const SizedBox(height: 24),

                          // Summary Card
                          transactions.when(
                            data: (txns) {
                              final today = DateTime.now();
                              final thisMonth = DateTime(today.year, today.month);
                              final monthTransactions = txns
                                  .where((t) => t.date.isAfter(
                                      DateTime(thisMonth.year, thisMonth.month)))
                                  .toList();

                              final income = monthTransactions
                                  .where((t) => t.isIncome)
                                  .fold<double>(0, (sum, t) => sum + t.amount);
                              final expenses = monthTransactions
                                  .where((t) => !t.isIncome)
                                  .fold<double>(0, (sum, t) => sum + t.amount);

                              return _SummaryCard(income: income, expenses: expenses);
                            },
                            loading: () => _SummaryCardSkeleton(),
                            error: (error, stackTrace) => Text('Error: $error'),
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions
                          Row(
                            children: [
                              Expanded(
                                child: _QuickActionButton(
                                  label: 'spend it ✌️',
                                  icon: '💸',
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (ctx) => const AddTransactionScreen(isIncome: false),
                                    );
                                  },
                                  bgColor: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionButton(
                                  label: 'got money 💰',
                                  icon: '📈',
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (ctx) => const AddTransactionScreen(isIncome: true),
                                    );
                                  },
                                  bgColor: AppTheme.accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Recent Transactions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'your vibe check',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'see all',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          transactions.when(
                            data: (txns) {
                              if (txns.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 32),
                                    child: Text(
                                      'no transactions yet. add your first one! 🎯',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: txns.take(5).length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final txn = txns[index];
                                  return _TransactionTile(transaction: txn);
                                },
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
              )
            : const AnalyticsScreen(),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => const AddTransactionScreen(isIncome: false),
                );
              },
              label: Text(
                '+ add transaction',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.add),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final walletMood;

  const _MoodCard({required this.walletMood});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "today's vibe",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                walletMood.moodEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      walletMood.moodMessage,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'score: ${walletMood.moodScore}/100',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      height: 120,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double income;
  final double expenses;

  const _SummaryCard({required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
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
            'this month',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rp ${expenses.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'in',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                  Text(
                    'Rp ${income.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'out',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                  Text(
                    'Rp ${expenses.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      height: 140,
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onPressed;
  final Color bgColor;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            alignment: Alignment.center,
            child: Text(transaction.categoryEmoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${transaction.category} • ${_formatDate(transaction.date)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isIncome ? '+' : '-'}Rp ${transaction.amount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: transaction.isIncome ? AppTheme.accentColor : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'today';
    } else if (date.day == now.day - 1 && date.month == now.month && date.year == now.year) {
      return 'yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
