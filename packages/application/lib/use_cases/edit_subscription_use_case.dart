import 'package:domain/domain.dart';

class EditSubscriptionUseCase {
  final SubscriptionRepository _repository;
  const EditSubscriptionUseCase(this._repository);
  Future<void> execute(Subscription s) => _repository.update(s);
}
