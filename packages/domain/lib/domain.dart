library domain;

export 'enums/transaction_type.dart';
export 'enums/survival_status.dart';
export 'enums/billing_cycle.dart';
export 'enums/subscription_category.dart';

export 'value_objects/money.dart';
export 'value_objects/survival_month.dart';

export 'entities/transaction.dart';
export 'entities/monthly_state.dart';
export 'entities/model_state.dart';
export 'entities/loan.dart';
export 'entities/loan_summary.dart';
export 'entities/subscription.dart';
export 'entities/budget.dart';

export 'repositories/transaction_repository.dart';
export 'repositories/loan_repository.dart';
export 'repositories/subscription_repository.dart';

export 'logic/monthly_aggregator.dart';
export 'logic/survival_engine.dart';
export 'logic/loan_engine.dart';
export 'logic/subscription_engine.dart';

export 'failures/domain_failure.dart';
