import 'package:domain/domain.dart';

class RestoreBackupUseCase {
  const RestoreBackupUseCase(this._repository);

  final BackupRepository _repository;

  Future<void> execute(BackupMetadata metadata) {
    return _repository.restoreBackup(metadata);
  }
}
