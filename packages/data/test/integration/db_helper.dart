import 'package:drift/native.dart';
import 'package:data/data.dart';

/// Opens a fresh in-memory database for each test.
/// Uses plain SQLite (no encryption) — safe for the test environment.
AppDatabase openTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());
