abstract class PurchaseService {
  /// Fetch available offerings. Returns null if unavailable or unconfigured.
  Future<ProOffering?> fetchOffering();

  /// Purchase the given package. Throws [PurchaseException] on failure.
  Future<bool> purchasePackage(ProPackage package);

  /// Restore previous purchases. Returns true if Pro entitlement is active.
  Future<bool> restorePurchases();

  /// Check if the Pro entitlement is currently active server-side.
  Future<bool> checkProEntitlement();
}

class ProOffering {
  final String identifier;
  final List<ProPackage> packages;
  const ProOffering({required this.identifier, required this.packages});
}

class ProPackage {
  final String identifier;
  final String priceString;
  final ProPackageType type;
  final Object nativePackage;
  const ProPackage({
    required this.identifier,
    required this.priceString,
    required this.type,
    required this.nativePackage,
  });
}

enum ProPackageType { monthly, annual, weekly, lifetime, unknown }

class PurchaseException implements Exception {
  final String message;
  final bool userCancelled;
  const PurchaseException(this.message, {this.userCancelled = false});

  @override
  String toString() => 'PurchaseException: $message';
}
