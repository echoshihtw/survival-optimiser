enum BackupProvider { icloud, google }

class BackupMetadata {
  final BackupProvider provider;
  final String backupId;
  final String deviceId;
  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sizeBytes;
  final String checksum;

  const BackupMetadata({
    required this.provider,
    required this.backupId,
    required this.deviceId,
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.sizeBytes,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
    'provider': provider.name,
    'backupId': backupId,
    'deviceId': deviceId,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'sizeBytes': sizeBytes,
    'checksum': checksum,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> j) => BackupMetadata(
    provider: BackupProvider.values.byName(j['provider'] as String),
    backupId: j['backupId'] as String,
    deviceId: j['deviceId'] as String,
    appVersion: j['appVersion'] as String,
    schemaVersion: j['schemaVersion'] as int,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    sizeBytes: j['sizeBytes'] as int,
    checksum: j['checksum'] as String,
  );
}
