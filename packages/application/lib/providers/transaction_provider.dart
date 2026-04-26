import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/add_transaction_use_case.dart';
import '../use_cases/edit_transaction_use_case.dart';
import '../use_cases/delete_transaction_use_case.dart';
import 'repository_provider.dart';

/// Streams all transactions live from SQLite
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// Use case providers
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final editTransactionUseCaseProvider = Provider<EditTransactionUseCase>((ref) {
  return EditTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((
  ref,
) {
  return DeleteTransactionUseCase(ref.watch(transactionRepositoryProvider));
});
