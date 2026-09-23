import 'package:pocki/domain/entities/additional_amount_entity.dart';
import 'package:pocki/domain/repositories/expense_repository.dart';

class GetAdditionalAmountsStreamUseCase {
  final ExpenseRepository _repository;
  GetAdditionalAmountsStreamUseCase(this._repository);

  Stream<List<AdditionalAmountEntity>> call(String userId, int month, int year) =>
      _repository.getAdditionalAmountsStream(userId, month, year);
}

class AddAdditionalAmountUseCase {
  final ExpenseRepository _repository;
  AddAdditionalAmountUseCase(this._repository);

  Future<void> call(AdditionalAmountEntity amount) =>
      _repository.addAdditionalAmount(amount);
}

class UpdateAdditionalAmountUseCase {
  final ExpenseRepository _repository;
  UpdateAdditionalAmountUseCase(this._repository);

  Future<void> call(AdditionalAmountEntity amount) =>
      _repository.updateAdditionalAmount(amount);
}

class DeleteAdditionalAmountUseCase {
  final ExpenseRepository _repository;
  DeleteAdditionalAmountUseCase(this._repository);

  Future<void> call(String userId, String additionalAmountId) =>
      _repository.deleteAdditionalAmount(userId, additionalAmountId);
}
