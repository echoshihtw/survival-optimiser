import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:domain/domain.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../database/app_database.dart';

abstract class EncryptedBackupRepository implements BackupRepository {
  EncryptedBackupRepository({required this.provider});

  static const backupFileName = 'runway_backup.enc';
  static const metadataFileName = 'runway_backup.json';
  static const _enabledPrefix = 'runway_backup_enabled_';
  static const _backupKeyPrefix = 'runway_backup_key_';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    aOptions: AndroidOptions(),
  );

  final BackupProvider provider;

  @override
  Future<void> createBackup(BackupProvider provider) async {
    _assertProvider(provider);
    final backupId = _backupId(provider);
    final dbFile = await runwayDatabaseFile();
    if (!await dbFile.exists()) {
      throw StateError('Local database does not exist yet.');
    }

    final encryptedBytes = await _encryptedDatabaseBytes(backupId, dbFile);
    final metadata = await _metadataFor(backupId, encryptedBytes);
    await uploadBackup(encryptedBytes, metadata);
    await _storage.write(key: _enabledKey(provider), value: 'true');
  }

  @override
  Future<BackupMetadata?> getLatestBackup(BackupProvider provider) async {
    _assertProvider(provider);
    return readRemoteMetadata();
  }

  @override
  Future<void> restoreBackup(BackupMetadata metadata) async {
    _assertProvider(metadata.provider);
    final encryptedBytes = await downloadBackup(metadata);
    final digest = await Sha256().hash(encryptedBytes);
    final checksum = hexFromBytes(digest.bytes);
    if (checksum != metadata.checksum) {
      throw StateError('Backup checksum mismatch.');
    }

    final decryptedBytes = await _decryptedDatabaseBytes(
      metadata.backupId,
      encryptedBytes,
    );
    final dbFile = await runwayDatabaseFile();
    await dbFile.parent.create(recursive: true);
    await _deleteDatabaseSidecars(dbFile);
    await dbFile.writeAsBytes(decryptedBytes, flush: true);
    await _storage.write(key: _enabledKey(metadata.provider), value: 'true');
  }

  @override
  Future<bool> isBackupEnabled(BackupProvider provider) async {
    _assertProvider(provider);
    return await _storage.read(key: _enabledKey(provider)) == 'true';
  }

  @override
  Future<void> disableBackup(BackupProvider provider) async {
    _assertProvider(provider);
    await _storage.delete(key: _enabledKey(provider));
    await clearRemoteMetadata();
  }

  Future<void> uploadBackup(List<int> encryptedBytes, BackupMetadata metadata);

  Future<List<int>> downloadBackup(BackupMetadata metadata);

  Future<BackupMetadata?> readRemoteMetadata();

  Future<void> clearRemoteMetadata();

  Future<BackupMetadata> _metadataFor(
    String backupId,
    List<int> encryptedBytes,
  ) async {
    final now = DateTime.now().toUtc();
    final packageInfo = await PackageInfo.fromPlatform();
    final digest = await Sha256().hash(encryptedBytes);
    return BackupMetadata(
      provider: provider,
      backupId: backupId,
      deviceId: await _deviceId(),
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      schemaVersion: runwayDatabaseSchemaVersion,
      createdAt: now,
      updatedAt: now,
      sizeBytes: encryptedBytes.length,
      checksum: hexFromBytes(digest.bytes),
    );
  }

  Future<List<int>> _encryptedDatabaseBytes(
    String backupId,
    File dbFile,
  ) async {
    final bytes = await dbFile.readAsBytes();
    final key = await _backupKey(backupId);
    final nonce = AesGcm.with256bits().newNonce();
    final secretBox = await AesGcm.with256bits().encrypt(
      bytes,
      secretKey: key,
      nonce: nonce,
    );
    return [
      ...utf8.encode('RWYB1'),
      ...nonce,
      ...secretBox.mac.bytes,
      ...secretBox.cipherText,
    ];
  }

  Future<List<int>> _decryptedDatabaseBytes(
    String backupId,
    List<int> encryptedBytes,
  ) async {
    final header = utf8.decode(encryptedBytes.take(5).toList());
    if (header != 'RWYB1') {
      throw StateError('Unsupported backup format.');
    }
    final nonce = encryptedBytes.sublist(5, 17);
    final mac = Mac(encryptedBytes.sublist(17, 33));
    final cipherText = encryptedBytes.sublist(33);
    final key = await _backupKey(backupId);
    return AesGcm.with256bits().decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: key,
    );
  }

  Future<SecretKey> _backupKey(String backupId) async {
    final keyName = '$_backupKeyPrefix$backupId';
    final storedKey = await _storage.read(key: keyName);
    if (storedKey != null) {
      return SecretKey(base64Url.decode(storedKey));
    }

    final dbKey = await runwayDatabaseKey();
    final dbKeyBytes = base64Url.decode(dbKey);
    final derived = await Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
      secretKey: SecretKey(dbKeyBytes),
      nonce: utf8.encode('runway-backup-v1'),
      info: utf8.encode(backupId),
    );
    final data = await derived.extractBytes();
    await _storage.write(key: keyName, value: base64Url.encode(data));
    return SecretKey(data);
  }

  Future<String> _deviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor ?? ios.name;
    }
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.id;
    }
    return Platform.localHostname;
  }

  void _assertProvider(BackupProvider requestedProvider) {
    if (requestedProvider != provider) {
      throw ArgumentError(
        'Repository handles $provider, not $requestedProvider',
      );
    }
  }

  static String metadataToJson(BackupMetadata metadata) =>
      jsonEncode(metadata.toJson());

  static BackupMetadata metadataFromJson(String source) =>
      BackupMetadata.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static String hexFromBytes(List<int> bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  static String _enabledKey(BackupProvider provider) =>
      '$_enabledPrefix${provider.name}';

  static String _backupId(BackupProvider provider) => 'runway_${provider.name}';

  static Future<void> _deleteDatabaseSidecars(File dbFile) async {
    for (final path in [
      dbFile.path,
      '${dbFile.path}-wal',
      '${dbFile.path}-shm',
    ]) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
