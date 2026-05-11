import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../use_cases/create_backup_use_case.dart';
import '../use_cases/restore_backup_use_case.dart';

class BackupState {
  final bool isEnabled;
  final BackupProvider? provider;
  final BackupMetadata? lastBackup;
  final bool isLoading;
  final String? error;

  const BackupState({
    required this.isEnabled,
    required this.provider,
    required this.lastBackup,
    required this.isLoading,
    required this.error,
  });

  const BackupState.initial()
    : isEnabled = false,
      provider = null,
      lastBackup = null,
      isLoading = false,
      error = null;

  BackupState copyWith({
    bool? isEnabled,
    BackupProvider? provider,
    BackupMetadata? lastBackup,
    bool? isLoading,
    String? error,
    bool clearProvider = false,
    bool clearBackup = false,
    bool clearError = false,
  }) {
    return BackupState(
      isEnabled: isEnabled ?? this.isEnabled,
      provider: clearProvider ? null : provider ?? this.provider,
      lastBackup: clearBackup ? null : lastBackup ?? this.lastBackup,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final backupRepositoryProvider =
    Provider.family<BackupRepository, BackupProvider>((ref, provider) {
      throw UnimplementedError(
        'backupRepositoryProvider($provider) must be overridden in main.dart',
      );
    });

final backupProvider = AsyncNotifierProvider<BackupNotifier, BackupState>(
  BackupNotifier.new,
);

class BackupNotifier extends AsyncNotifier<BackupState> {
  @override
  Future<BackupState> build() async {
    for (final provider in BackupProvider.values) {
      final repository = ref.read(backupRepositoryProvider(provider));
      final enabled = await repository.isBackupEnabled(provider);
      if (enabled) {
        return BackupState(
          isEnabled: true,
          provider: provider,
          lastBackup: await repository.getLatestBackup(provider),
          isLoading: false,
          error: null,
        );
      }
    }
    return const BackupState.initial();
  }

  Future<void> enable(BackupProvider provider) async {
    state = AsyncData(
      (state.value ?? const BackupState.initial()).copyWith(
        isLoading: true,
        clearError: true,
      ),
    );
    try {
      final repository = ref.read(backupRepositoryProvider(provider));
      await CreateBackupUseCase(repository).execute(provider);
      final metadata = await repository.getLatestBackup(provider);
      state = AsyncData(
        BackupState(
          isEnabled: true,
          provider: provider,
          lastBackup: metadata,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      state = AsyncData(
        (state.value ?? const BackupState.initial()).copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> backUpNow() async {
    final current = state.value;
    final provider = current?.provider;
    if (provider == null) return;
    await enable(provider);
  }

  Future<void> restore(BackupMetadata metadata) async {
    state = AsyncData(
      (state.value ?? const BackupState.initial()).copyWith(
        isLoading: true,
        clearError: true,
      ),
    );
    try {
      final repository = ref.read(backupRepositoryProvider(metadata.provider));
      await RestoreBackupUseCase(repository).execute(metadata);
      state = AsyncData(
        BackupState(
          isEnabled: true,
          provider: metadata.provider,
          lastBackup: metadata,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      state = AsyncData(
        (state.value ?? const BackupState.initial()).copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> disable() async {
    final current = state.value;
    final provider = current?.provider;
    if (provider == null) return;
    final repository = ref.read(backupRepositoryProvider(provider));
    await repository.disableBackup(provider);
    state = const AsyncData(BackupState.initial());
  }
}
