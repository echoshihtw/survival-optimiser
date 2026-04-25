import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/add_subscription_use_case.dart';
import '../use_cases/edit_subscription_use_case.dart';
import '../use_cases/delete_subscription_use_case.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  throw UnimplementedError(
      'subscriptionRepositoryProvider must be overridden in main.dart');
});

final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchAll();
});

final subscriptionMonthlyTotalProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider).value ?? [];
  return totalSubscriptionMonthlyCost(subs);
});

final addSubscriptionUseCaseProvider = Provider<AddSubscriptionUseCase>((ref) {
  return AddSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final editSubscriptionUseCaseProvider =
    Provider<EditSubscriptionUseCase>((ref) {
  return EditSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final deleteSubscriptionUseCaseProvider =
    Provider<DeleteSubscriptionUseCase>((ref) {
  return DeleteSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});
