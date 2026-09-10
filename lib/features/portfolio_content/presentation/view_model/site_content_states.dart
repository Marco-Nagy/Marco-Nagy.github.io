import 'package:flutter/foundation.dart' show immutable;

import '../../domain/entities/site_content.dart';

/// Deliberately has no `Loading` case.
///
/// [SiteContent] feeds the nav bar, the footer and the splash mark — chrome
/// that is on screen before any read completes. A loading state would invite a
/// consumer to render a spinner there, so the cubit exposes a non-nullable
/// field instead and these states exist only to trigger a rebuild.
@immutable
sealed class SiteContentState {
  const SiteContentState();
}

class SiteContentInitial extends SiteContentState {
  const SiteContentInitial();
}

class SiteContentReady extends SiteContentState {
  const SiteContentReady(this.content);
  final SiteContent content;
}

/// A read or save failed. The cubit's field still holds the last good value,
/// so this is for the admin form to report — never for chrome to render.
class SiteContentFailure extends SiteContentState {
  const SiteContentFailure(this.message);
  final String message;
}
