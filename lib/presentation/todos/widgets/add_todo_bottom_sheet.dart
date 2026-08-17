import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/todo_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/todos/bloc/todo_bloc.dart';

class AddTodoBottomSheet extends StatefulWidget {
  final TodoEntity? todoToEdit;

  const AddTodoBottomSheet({super.key, this.todoToEdit});

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  late final TextEditingController _taskController;
  late final TextEditingController _noteController;

  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _selectedTime;

  bool get _isEditing => widget.todoToEdit != null;

  @override
  void initState() {
    super.initState();
    final todo = widget.todoToEdit;
    _taskController = TextEditingController(text: todo?.title ?? '');
    _noteController = TextEditingController(text: todo?.description ?? '');
    _startDate = todo?.startDate ?? DateTime.now();
    _endDate = todo?.endDate ?? DateTime.now();

    if (todo != null && todo.timeString.isNotEmpty) {
      try {
        final parsed = DateFormat.jm().parse(todo.timeString);
        _selectedTime = TimeOfDay(hour: parsed.hour, minute: parsed.minute);
      } catch (_) {
        _selectedTime = const TimeOfDay(hour: 18, minute: 0);
      }
    } else {
      _selectedTime = const TimeOfDay(hour: 18, minute: 0);
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PockiColors.secondaryPurple,
              onPrimary: Colors.white,
              onSurface: PockiColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PockiColors.secondaryPurple,
              onPrimary: Colors.white,
              onSurface: PockiColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PockiColors.secondaryPurple,
              onPrimary: Colors.white,
              onSurface: PockiColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveTodo() {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a task title 📝"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) return;

    final formattedTime = _selectedTime.format(context);

    if (_isEditing) {
      final updatedTodo = widget.todoToEdit!.copyWith(
        title: title,
        description: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        timeString: formattedTime,
        updatedAt: DateTime.now(),
      );
      context.read<TodoBloc>().add(UpdateTodoSubmittedEvent(updatedTodo));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task updated! ✨"),
          backgroundColor: PockiColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final todo = TodoEntity(
        id: const Uuid().v4(),
        userId: authState.user.uid,
        title: title,
        startDate: _startDate,
        endDate: _endDate,
        timeString: formattedTime,
        description: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        completed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<TodoBloc>().add(AddTodoSubmittedEvent(todo));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task added to your list! 🚀✨"),
          backgroundColor: PockiColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

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
                  _isEditing ? "Edit Todo" : "Add Todo",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                GestureDetector(
                  onTap: _saveTodo,
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
              "What's the task?",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                hintText: "Finish Pocki UI 🎨",
                suffixIcon: Icon(Icons.edit_outlined, size: 18, color: PockiColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Note / Description (Optional)",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: "Add extra details...",
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time Selectors Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Start Date 📅",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickStartDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: PockiColors.secondaryPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dateFormat.format(_startDate),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "End Date 📅",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickEndDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_rounded, size: 16, color: PockiColors.secondaryPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dateFormat.format(_endDate),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Time Selector
            const Text(
              "Reminder Time ⏰",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 18, color: PockiColors.primaryPink),
                    const SizedBox(width: 10),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, size: 14, color: PockiColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _saveTodo,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: PockiColors.purpleGradient,
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
                    _isEditing ? "Update Todo" : "Add Todo",
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
      ),
    );
  }
}
