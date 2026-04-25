enum SubscriptionCategory {
  personal,
  business;

  String get label => switch (this) {
    SubscriptionCategory.personal => 'PERSONAL',
    SubscriptionCategory.business => 'BUSINESS',
  };
}
