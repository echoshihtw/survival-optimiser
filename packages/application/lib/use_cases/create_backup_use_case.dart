import 'package:domain/domain.dart';

class CreateBackupUseCase {
  const CreateBackupUseCase(this._repository);

  final BackupRepository _repository;

  Future<void> execute(BackupProvider provider) {
    return _repository.createBackup(provider);
  }
}
