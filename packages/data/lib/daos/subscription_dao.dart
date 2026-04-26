import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/subscriptions_table.dart';

part 'subscription_dao.g.dart';

@DriftAccessor(tables: [Subscriptions])
class SubscriptionDao extends DatabaseAccessor<AppDatabase>
    with _$SubscriptionDaoMixin {
  SubscriptionDao(super.db);

  Stream<List<Subscription>> watchAll() => select(subscriptions).watch();

  Future<List<Subscription>> getAll() => select(subscriptions).get();

  Future<void> insertSubscription(SubscriptionsCompanion entry) =>
      into(subscriptions).insert(entry);

  Future<void> updateSubscription(SubscriptionsCompanion entry) => (update(
    subscriptions,
  )..where((t) => t.id.equals(entry.id.value))).write(entry);

  Future<void> deleteSubscription(String id) =>
      (delete(subscriptions)..where((t) => t.id.equals(id))).go();
}
