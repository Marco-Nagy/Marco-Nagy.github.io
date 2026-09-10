import 'package:flutter/foundation.dart' show immutable;

import '../../domain/entities/section_definition.dart';

/// No `Loading` case, for the same reason as `SiteContentState`: the nav bar
/// and drawer read this, and chrome must never render a spinner.
@immutable
sealed class SectionsState {
  const SectionsState();
}

class SectionsInitial extends SectionsState {
  const SectionsInitial();
}

class SectionsReady extends SectionsState {
  const SectionsReady(this.sections);
  final List<SectionDefinition> sections;
}

class SectionsFailure extends SectionsState {
  const SectionsFailure(this.message);
  final String message;
}
