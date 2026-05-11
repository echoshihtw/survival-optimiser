import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../tables/transactions_table.dart';
import '../tables/loans_table.dart';
import '../tables/subscriptions_table.dart';
import '../daos/transaction_dao.dart';
import '../daos/loan_dao.dart';
import '../daos/subscription_dao.dart';

part 'app_database.g.dart';

const runwayDatabaseSchemaVersion = 4;

@DriftDatabase(
  tables: [Transactions, Loans, Subscriptions],
  daos: [TransactionDao, LoanDao, SubscriptionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => runwayDatabaseSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(transactions, transactions.loanId);
        await m.createTable(loans);
      }
      if (from < 3) {
        await m.createTable(subscriptions);
      }
      if (from < 4) {
        await m.addColumn(loans, loans.originalTermMonths);
      }
    },
  );
}

Future<File> runwayDatabaseFile() async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return File(p.join(dir.path, 'survival.db'));
}

Future<String> runwayDatabaseKey() => _getOrCreateKey();

/// Retrieves or creates a secure encryption key
/// Stored in iOS Secure Enclave / Android Keystore
/// Never stored in plain text or SharedPreferences
Future<String> _getOrCreateKey() async {
  const storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    aOptions: AndroidOptions(),
  );

  const keyName = 'awareness_db_key';
  var key = await storage.read(key: keyName);

  if (key == null) {
    // Generate a cryptographically secure 256-bit key
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    key = base64Url.encode(keyBytes);
    await storage.write(key: keyName, value: key);
  }

  return key;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await runwayDatabaseFile();
    final dbKey = await _getOrCreateKey();
    final pragmaKey = "PRAGMA key = '$dbKey';";
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        try {
          db.execute(pragmaKey);
          db.execute('SELECT count(*) FROM sqlite_master;');
          db.execute('PRAGMA journal_mode=WAL;');
        } catch (_) {
          // Key mismatch: DB was restored from backup without its encryption key.
          // Delete the unreadable file; the next launch will create a fresh DB.
          if (file.existsSync()) {
            file.deleteSync();
          }
          db.execute(pragmaKey);
          db.execute('PRAGMA journal_mode=WAL;');
        }
      },
    );
  });
}
