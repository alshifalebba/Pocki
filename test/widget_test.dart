import 'package:flutter_test/flutter_test.dart';
import 'package:pocki/domain/entities/todo_entity.dart';
import 'package:pocki/domain/entities/user_entity.dart';

void main() {
  test('UserEntity default instantiation test', () {
    final user = UserEntity.defaultUser('uid123', 'test@pocki.com');
    expect(user.name, 'Pocki User');
    expect(user.nickname, 'pocki_user');
    expect(user.monthlyBudget, 15000.0);
  });

  test('Multi-day Todo Task active date range logic', () {
    final start = DateTime(2026, 8, 10);
    final end = DateTime(2026, 8, 12);
    final task = TodoEntity(
      id: 'task_1',
      userId: 'uid123',
      title: 'Finish Pocki UI',
      startDate: start,
      endDate: end,
      timeString: '06:00 PM',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(task.isActiveOnDate(DateTime(2026, 8, 10)), isTrue);
    expect(task.isActiveOnDate(DateTime(2026, 8, 11)), isTrue);
    expect(task.isActiveOnDate(DateTime(2026, 8, 12)), isTrue);
    expect(task.isActiveOnDate(DateTime(2026, 8, 13)), isFalse);
    expect(task.isActiveOnDate(DateTime(2026, 8, 9)), isFalse);
  });
}
