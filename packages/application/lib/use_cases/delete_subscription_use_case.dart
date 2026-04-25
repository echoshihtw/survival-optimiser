import 'package:domain/domain.dart';

class DeleteSubscriptionUseCase {
  final SubscriptionRepository _repository;
  const DeleteSubscriptionUseCase(this._repository);
  Future<void> execute(String id) => _repository.delete(id);
}
