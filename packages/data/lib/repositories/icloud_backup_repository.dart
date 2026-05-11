import 'dart:io';

import 'package:domain/domain.dart';
import 'package:flutter/services.dart';

import 'encrypted_backup_repository.dart';

class ICloudBackupRepository extends EncryptedBackupRepository {
  ICloudBackupRepository() : super(provider: BackupProvider.icloud);

  static const _channel = MethodChannel('runway/icloud_backup');

  @override
  Future<void> uploadBackup(
    List<int> encryptedBytes,
    BackupMetadata metadata,
  ) async {
    final directory = await _documentsDirectory();
    await File(
      '${directory.path}/${EncryptedBackupRepository.backupFileName}',
    ).writeAsBytes(encryptedBytes, flush: true);
    final metadataJson = EncryptedBackupRepository.metadataToJson(metadata);
    await File(
      '${directory.path}/${EncryptedBackupRepository.metadataFileName}',
    ).writeAsString(metadataJson, flush: true);
    await _channel.invokeMethod<void>('setMetadata', {
      'metadata': metadataJson,
    });
  }

  @override
  Future<List<int>> downloadBackup(BackupMetadata metadata) async {
    final directory = await _documentsDirectory();
    return File(
      '${directory.path}/${EncryptedBackupRepository.backupFileName}',
    ).readAsBytes();
  }

  @override
  Future<BackupMetadata?> readRemoteMetadata() async {
    final metadata = await _channel.invokeMethod<String>('getMetadata');
    if (metadata != null && metadata.isNotEmpty) {
      return EncryptedBackupRepository.metadataFromJson(metadata);
    }

    final directory = await _documentsDirectory();
    final file = File(
      '${directory.path}/${EncryptedBackupRepository.metadataFileName}',
    );
    if (!await file.exists()) return null;
    return EncryptedBackupRepository.metadataFromJson(
      await file.readAsString(),
    );
  }

  @override
  Future<void> clearRemoteMetadata() async {
    await _channel.invokeMethod<void>('clearMetadata');
  }

  Future<Directory> _documentsDirectory() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('iCloud backup is only available on iOS.');
    }
    final path = await _channel.invokeMethod<String>('documentsPath');
    if (path == null || path.isEmpty) {
      throw StateError('iCloud container is not available.');
    }
    final directory = Directory(path);
    await directory.create(recursive: true);
    return directory;
  }
}
