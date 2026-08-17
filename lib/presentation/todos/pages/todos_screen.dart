import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/todo_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/todos/bloc/todo_bloc.dart';
import '../widgets/add_todo_bottom_sheet.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      context.read<TodoBloc>().add(LoadTodosEvent(authState.user.uid));
    }
  }

  void _openAddTodo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTodoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: PockiColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthenticatedState) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocBuilder<TodoBloc, TodoState>(
              builder: (context, todoState) {
                List<TodoEntity> todos = [];
                if (todoState is TodoLoadedState) {
                  todos = todoState.todos;
                }

                List<TodoEntity> tasksToDisplay = todos;
                if (_selectedFilter == 'Today') {
                  tasksToDisplay = todos.where((t) => t.isActiveOnDate(today) && !t.completed).toList();
                } else if (_selectedFilter == 'Upcoming') {
                  tasksToDisplay = todos.where((t) => t.startDate.isAfter(today) && !t.completed).toList();
                } else if (_selectedFilter == 'Completed') {
                  tasksToDisplay = todos.where((t) => t.completed).toList();
                }

                return Column(
                  children: [
                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("☑️", style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Text("Todos", style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(width: 4),
                              const Text("✨", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          GestureDetector(
                            onTap: _openAddTodo,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: PockiColors.navDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        children: ['All', 'Today', 'Upcoming', 'Completed'].map((tab) {
                          final isSelected = _selectedFilter == tab;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = tab),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? PockiColors.primaryPink : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : PockiColors.textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: tasksToDisplay.isEmpty
                              ? [
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40.0),
                                      child: Column(
                                        children: [
                                          Text("🎉", style: TextStyle(fontSize: 48)),
                                          SizedBox(height: 12),
                                          Text("Nothing to do here! 🎉", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  )
                                ]
                              : tasksToDisplay.map((task) => _buildTodoCard(task)).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTodoCard(TodoEntity task) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddTodoBottomSheet(todoToEdit: task),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                context.read<TodoBloc>().add(ToggleTodoCompletedEvent(task));
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: task.completed ? PockiColors.mintGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.completed ? PockiColors.successGreen : const Color(0xFFD4C7E0),
                    width: 2,
                  ),
                ),
                child: task.completed
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: task.completed ? PockiColors.textMuted : PockiColors.textDark,
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.completed ? "Completed 🎉" : "Due ${task.durationBadgeText.toLowerCase()}, ${task.timeString}",
                    style: TextStyle(
                      fontSize: 11,
                      color: task.completed ? PockiColors.successGreen : PockiColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (!task.completed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PockiColors.pinkTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  task.durationBadgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PockiColors.primaryPink,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: PockiColors.mintTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: PockiColors.successGreen, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
