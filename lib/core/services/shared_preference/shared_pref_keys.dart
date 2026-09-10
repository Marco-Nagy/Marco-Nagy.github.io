class SharedPrefKeys {
  const SharedPrefKeys._();

  static const String language = 'language';

  // Built-in section content, stored as JSON strings.
  static const String projects = 'portfolio_projects';
  static const String certificates = 'portfolio_certificates';
  static const String workHistory = 'portfolio_work_history';
  static const String pricingPackages = 'portfolio_pricing_packages';
  static const String pricingAddOns = 'portfolio_pricing_add_ons';

  // Site-wide editable content.
  static const String siteContent = 'portfolio_site_content';
  static const String skillGroups = 'portfolio_skill_groups';
  static const String techBadges = 'portfolio_tech_badges';

  /// Nav metadata for built-in sections plus full definitions for custom ones.
  static const String sectionDefinitions = 'portfolio_section_definitions';

  /// Custom section content is stored per section so deleting a section can
  /// drop its items in one call.
  static String customSectionItems(String sectionId) =>
      'portfolio_custom_items_$sectionId';

  /// Prefix used to sweep every custom-items key when resetting.
  static const String customSectionItemsPrefix = 'portfolio_custom_items_';

  /// The [contentVersion] of the cached bundle. Compared against the value in
  /// Firestore's `content/meta` to decide whether the cache is still current,
  /// which is what keeps a returning visitor at a single Firestore read.
  static const String contentVersion = 'portfolio_content_version';

  /// The [schemaVersion] the cache was written with, so a cache produced by a
  /// newer build is discarded rather than half-decoded.
  static const String schemaVersion = 'portfolio_schema_version';
}
