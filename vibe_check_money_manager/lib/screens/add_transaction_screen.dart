import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/transactions_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final bool isIncome;

  const AddTransactionScreen({
    Key? key,
    required this.isIncome,
  }) : super(key: key);

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late String selectedCategory;
  late TextEditingController amountController;
  late TextEditingController labelController;
  late DateTime selectedDate;
  bool isLoading = false;

  final categoryEmojis = {
    'food & drinks': '🍔',
    'transportation': '🚗',
    'entertainment': '🎮',
    'shopping': '🛍️',
    'utilities': '💡',
    'health': '🏥',
    'work': '💼',
    'other': '📌',
    'salary': '💰',
    'freelance': '💻',
    'investments': '📈',
    'bonus': '🎁',
  };

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.isIncome ? 'salary' : 'food & drinks';
    amountController = TextEditingController();
    labelController = TextEditingController();
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    amountController.dispose();
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardHeight + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                "what's the vibe?",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Amount Input
              Text(
                'amount',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: 'Rp ',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Label Input
              Text(
                'what was it for?',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  hintText: 'e.g., coffee date, rent, freelance gig',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Category Selection
              Text(
                'category vibe',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryEmojis.entries
                    .where((e) {
                      if (widget.isIncome) {
                        return ['salary', 'freelance', 'investments', 'bonus'].contains(e.key);
                      } else {
                        return !['salary', 'freelance', 'investments', 'bonus'].contains(e.key);
                      }
                    })
                    .map((entry) {
                  bool isSelected = selectedCategory == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = entry.key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.value, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            entry.key,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'add to vibe check 🎯',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitTransaction() async {
    if (amountController.text.isEmpty || labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final amount = double.parse(amountController.text);
      final categoryEmoji = categoryEmojis[selectedCategory]!;

      await ref.read(transactionsNotifierProvider.notifier).addTransaction(
            amount: amount,
            label: labelController.text,
            category: selectedCategory,
            categoryEmoji: categoryEmoji,
            isIncome: widget.isIncome,
            date: selectedDate,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isIncome ? 'Income added! 💰' : 'Expense added! 💸'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
