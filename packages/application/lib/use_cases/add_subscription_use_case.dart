import 'package:domain/domain.dart';

class AddSubscriptionUseCase {
  final SubscriptionRepository _repository;
  const AddSubscriptionUseCase(this._repository);
  Future<void> execute(Subscription s) => _repository.add(s);
}
