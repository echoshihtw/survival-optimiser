library domain;

// Enums
export 'enums/transaction_type.dart';
export 'enums/survival_status.dart';

// Value Objects
export 'value_objects/money.dart';
export 'value_objects/survival_month.dart';

// Entities
export 'entities/transaction.dart';
export 'entities/monthly_state.dart';
export 'entities/model_state.dart';
export 'entities/loan.dart';
export 'entities/loan_summary.dart';

// Repository interfaces
export 'repositories/transaction_repository.dart';
export 'repositories/loan_repository.dart';

// Logic
export 'logic/monthly_aggregator.dart';
export 'logic/survival_engine.dart';
export 'logic/loan_engine.dart';

// Failures
export 'failures/domain_failure.dart';
