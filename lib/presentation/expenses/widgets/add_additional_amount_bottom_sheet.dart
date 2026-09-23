import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/additional_amount_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/expenses/bloc/expense_bloc.dart';

class AddAdditionalAmountBottomSheet extends StatefulWidget {
  final AdditionalAmountEntity? itemToEdit;
  const AddAdditionalAmountBottomSheet({super.key, this.itemToEdit});

  @override
  State<AddAdditionalAmountBottomSheet> createState() =>
      _AddAdditionalAmountBottomSheetState();
}

class _AddAdditionalAmountBottomSheetState
    extends State<AddAdditionalAmountBottomSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.itemToEdit != null
          ? widget.itemToEdit!.amount.toStringAsFixed(0)
          : '',
    );
    _noteController = TextEditingController(
      text: widget.itemToEdit?.note ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an amount 💰"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid positive amount 😅"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) return;

    final now = DateTime.now();
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    if (widget.itemToEdit != null) {
      final updated = widget.itemToEdit!.copyWith(
        amount: amount,
        note: note,
        updatedAt: now,
      );
      context
          .read<ExpenseBloc>()
          .add(UpdateAdditionalAmountSubmittedEvent(updated));
    } else {
      final newAmount = AdditionalAmountEntity(
        id: const Uuid().v4(),
        userId: authState.user.uid,
        amount: amount,
        note: note,
        month: now.month,
        year: now.year,
        createdAt: now,
        updatedAt: now,
      );
      context
          .read<ExpenseBloc>()
          .add(AddAdditionalAmountSubmittedEvent(newAmount));
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.itemToEdit != null
            ? "Additional amount updated! 💰✨"
            : "Additional amount added! 💰✨"),
        backgroundColor: PockiColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.itemToEdit != null;
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
                isEdit ? "Edit Additional Amount" : "Add Additional Amount",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: PockiColors.secondaryPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Helpful subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: PockiColors.purpleTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Text("💡", style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "This adds to your available budget — it is NOT counted as an expense.",
                    style: TextStyle(
                      fontSize: 12,
                      color: PockiColors.secondaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Amount",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: PockiColors.textMuted),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixText: "₹ ",
              prefixStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PockiColors.textDark),
              hintText: "2000",
              suffixIcon: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("💰", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            "Source / Note (optional)",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: PockiColors.textMuted),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: "e.g. Salary, Bonus, Gift, Freelance...",
              suffixIcon:
                  Icon(Icons.edit_outlined, size: 18, color: PockiColors.textMuted),
            ),
          ),
          const SizedBox(height: 28),

          GestureDetector(
            onTap: _save,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PockiColors.secondaryPurple,
                    PockiColors.secondaryPurple.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: PockiColors.secondaryPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isEdit ? "Save Changes" : "Add to Budget 💰",
                  style: const TextStyle(
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
    );
  }
}
