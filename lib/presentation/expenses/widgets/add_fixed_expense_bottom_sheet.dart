import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/fixed_expense_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/expenses/bloc/expense_bloc.dart';

class AddFixedExpenseBottomSheet extends StatefulWidget {
  final FixedExpenseEntity? fixedExpenseToEdit;

  const AddFixedExpenseBottomSheet({super.key, this.fixedExpenseToEdit});

  @override
  State<AddFixedExpenseBottomSheet> createState() => _AddFixedExpenseBottomSheetState();
}

class _AddFixedExpenseBottomSheetState extends State<AddFixedExpenseBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  String _selectedCategory = 'Subscriptions';

  bool get _isEditing => widget.fixedExpenseToEdit != null;

  final List<String> _categories = [
    'Subscriptions',
    'Rent',
    'Internet',
    'EMI',
    'Utilities',
    'Insurance',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.fixedExpenseToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _amountController = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(0) : '',
    );
    if (item != null && _categories.contains(item.category)) {
      _selectedCategory = item.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveFixedExpense() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Expense name cannot be empty 📌"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid positive amount 💰"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) return;

    if (_isEditing) {
      final updated = widget.fixedExpenseToEdit!.copyWith(
        name: name,
        amount: amount,
        category: _selectedCategory,
        updatedAt: DateTime.now(),
      );
      context.read<ExpenseBloc>().add(UpdateFixedExpenseSubmittedEvent(updated));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fixed expense updated! ✏️✨"),
          backgroundColor: PockiColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final fixedExpense = FixedExpenseEntity(
        id: const Uuid().v4(),
        userId: authState.user.uid,
        name: name,
        amount: amount,
        category: _selectedCategory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<ExpenseBloc>().add(AddFixedExpenseSubmittedEvent(fixedExpense));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fixed expense added! 📌✨"),
          backgroundColor: PockiColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                  _isEditing ? "Edit Fixed Expense" : "Add Fixed Expense",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                GestureDetector(
                  onTap: _saveFixedExpense,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: PockiColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              "Expense Name",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "e.g. Rent, Netflix, Internet",
                prefixIcon: Icon(Icons.receipt_long_rounded, color: PockiColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Monthly Amount (₹)",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: "e.g. 8000",
                prefixText: "₹ ",
                prefixIcon: Icon(Icons.currency_rupee_rounded, color: PockiColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Category",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? PockiColors.secondaryPurple : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? PockiColors.secondaryPurple : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : PockiColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: PockiColors.textMuted, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _saveFixedExpense,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: PockiColors.purpleGradient,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: PockiColors.secondaryPurple.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isEditing ? "Update" : "Save",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
