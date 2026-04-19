sealed class DomainFailure {
  final String message;
  const DomainFailure(this.message);
}

class InsufficientDataFailure extends DomainFailure {
  const InsufficientDataFailure() : super('Not enough data to compute model');
}

class InvalidTransactionFailure extends DomainFailure {
  const InvalidTransactionFailure(super.message);
}

class StorageFailure extends DomainFailure {
  const StorageFailure(super.message);
}
