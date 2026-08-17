import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/expense_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/expenses/bloc/expense_bloc.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  const AddExpenseBottomSheet({super.key});

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _otherDetailsController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  final TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _otherDetailsController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an amount 💸"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid amount 😅"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }

    if (_selectedCategory == ExpenseCategory.other &&
        _otherDetailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("What did you spend on? Required for Other ✨"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) return;

    final formattedTime = _selectedTime.format(context);

    final expense = ExpenseEntity(
      id: const Uuid().v4(),
      userId: authState.user.uid,
      category: _selectedCategory,
      amount: amount,
      dateTime: _selectedDate,
      timeString: formattedTime,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      otherDetails: _selectedCategory == ExpenseCategory.other
          ? _otherDetailsController.text.trim()
          : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<ExpenseBloc>().add(AddExpenseSubmittedEvent(expense));
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Expense added! 💸✨"),
        backgroundColor: PockiColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: PockiColors.lightBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
                Text(
                  "Add Expense",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: PockiColors.primaryPink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? PockiColors.pinkTint : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? PockiColors.primaryPink : const Color(0xFFF0E6F4),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 4),
                          Text(
                            cat.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? PockiColors.primaryPink : PockiColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Amount",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: "₹ ",
                prefixStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                hintText: "250",
                suffixIcon: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("👛", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedCategory == ExpenseCategory.other) ...[
              const Text(
                "Other Details (required)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.primaryPink),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otherDetailsController,
                decoration: const InputDecoration(
                  hintText: "What did you spend on?",
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              "Note (optional)",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: "Add a note...",
                suffixIcon: Icon(Icons.edit_outlined, size: 18, color: PockiColors.textMuted),
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _saveExpense,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: PockiColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: PockiColors.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Add Expense",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
