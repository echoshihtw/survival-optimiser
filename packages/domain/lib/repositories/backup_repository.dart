import '../entities/backup_metadata.dart';

abstract class BackupRepository {
  Future<void> createBackup(BackupProvider provider);
  Future<BackupMetadata?> getLatestBackup(BackupProvider provider);
  Future<void> restoreBackup(BackupMetadata metadata);
  Future<bool> isBackupEnabled(BackupProvider provider);
  Future<void> disableBackup(BackupProvider provider);
}
