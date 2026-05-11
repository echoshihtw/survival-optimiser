import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import 'encrypted_backup_repository.dart';

class GDriveBackupRepository extends EncryptedBackupRepository {
  GDriveBackupRepository() : super(provider: BackupProvider.google);

  static const _scopes = ['https://www.googleapis.com/auth/drive.appdata'];

  final GoogleSignIn _signIn = GoogleSignIn(scopes: _scopes);

  @override
  Future<void> uploadBackup(
    List<int> encryptedBytes,
    BackupMetadata metadata,
  ) async {
    final api = await _driveApi();
    await _upsertFile(
      api,
      EncryptedBackupRepository.backupFileName,
      encryptedBytes,
      'application/octet-stream',
    );
    await _upsertFile(
      api,
      EncryptedBackupRepository.metadataFileName,
      utf8.encode(EncryptedBackupRepository.metadataToJson(metadata)),
      'application/json',
    );
  }

  @override
  Future<List<int>> downloadBackup(BackupMetadata metadata) async {
    final api = await _driveApi();
    final id = await _fileId(api, EncryptedBackupRepository.backupFileName);
    if (id == null) throw StateError('No Google Drive backup found.');
    final media =
        await api.files.get(
              id,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  @override
  Future<BackupMetadata?> readRemoteMetadata() async {
    final api = await _driveApi();
    final id = await _fileId(api, EncryptedBackupRepository.metadataFileName);
    if (id == null) return null;
    final media =
        await api.files.get(
              id,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return EncryptedBackupRepository.metadataFromJson(utf8.decode(bytes));
  }

  @override
  Future<void> clearRemoteMetadata() async {
    final api = await _driveApi();
    final id = await _fileId(api, EncryptedBackupRepository.metadataFileName);
    if (id != null) {
      await api.files.delete(id);
    }
  }

  Future<drive.DriveApi> _driveApi() async {
    final account = await _signIn.signInSilently() ?? await _signIn.signIn();
    if (account == null) {
      throw StateError('Google sign-in was cancelled.');
    }
    return drive.DriveApi(_GoogleAuthClient(await account.authHeaders));
  }

  Future<String?> _fileId(drive.DriveApi api, String name) async {
    final result = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$name' and trashed = false",
      $fields: 'files(id, name, modifiedTime)',
      pageSize: 1,
    );
    final files = result.files ?? const [];
    return files.isEmpty ? null : files.first.id;
  }

  Future<void> _upsertFile(
    drive.DriveApi api,
    String name,
    List<int> bytes,
    String contentType,
  ) async {
    final existingId = await _fileId(api, name);
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: contentType,
    );
    final file = drive.File()
      ..name = name
      ..parents = existingId == null ? ['appDataFolder'] : null;

    if (existingId == null) {
      await api.files.create(file, uploadMedia: media);
    } else {
      await api.files.update(file, existingId, uploadMedia: media);
    }
  }
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
