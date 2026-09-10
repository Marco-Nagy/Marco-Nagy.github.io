import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/portfolio_content/domain/entities/section_definition.dart';
import '../../../features/portfolio_content/domain/entities/site_content.dart';
import '../../../features/portfolio_content/domain/entities/tech_badge_entity.dart';
import '../../../features/portfolio_content/presentation/view_data/chips_group_data.dart';
import '../../../features/portfolio_content/presentation/view_data/site_links.dart';
import '../../../features/portfolio_content/presentation/view_model/sections_view_model.dart';
import '../../../features/portfolio_content/presentation/view_model/site_content_view_model.dart';
import '../../../features/portfolio_content/presentation/view_model/skills_view_model.dart';
import 'context_extensions.dart';

/// Reading editable content from a widget.
///
/// Every getter here `watch`es its cubit, so a widget that reads content
/// rebuilds when the content changes — no `BlocBuilder` at each call site.
/// That is only safe because the three content cubits are provided above
/// `MaterialApp`: a widget anywhere in the app can find them, including the
/// nav bar and footer inside `PortfolioScaffold`, which sit below every
/// screen's own provider.
///
/// Nothing here returns null or throws a not-found. The cubits expose
/// non-nullable fields with defaults, which is what lets chrome paint before
/// any read has landed instead of showing a spinner or an error.
extension SiteContentContext on BuildContext {
  /// The site-wide singleton copy: identity, hero, about, contact, footer.
  SiteContent get site => watch<SiteContentCubit>().content;

  /// Outward URLs, resolved from [site] for this platform.
  SiteLinks get siteLinks => SiteLinks.fromSiteContent(site, isWeb: kIsWeb);

  /// Sections the nav should show — hidden ones dropped, `order` applied.
  List<SectionDefinition> get visibleSections => watch<SectionsCubit>().visible;

  /// A section's heading in the active language.
  ///
  /// Empty when that section has been hidden, deleted, or has not loaded yet,
  /// so the header renders blank for a frame rather than falling back to a
  /// hardcoded label that the admin can no longer change.
  String sectionTitle(String sectionId) {
    final section = watch<SectionsCubit>().byId(sectionId);
    if (section == null) return '';
    return localized(section.titleEn, section.titleAr);
  }

  /// Skill chips, grouped and localized, ready for the About block.
  List<ChipsGroupData> get skillGroups {
    final isArabic = this.isArabic;
    return watch<SkillsCubit>().orderedGroups
        .map((group) => ChipsGroupData.fromSkillGroup(group, isArabic))
        .toList(growable: false);
  }

  /// Badges orbiting the hero photo, in `order`.
  List<TechBadgeEntity> get techBadges => watch<SkillsCubit>().orderedBadges;
}
