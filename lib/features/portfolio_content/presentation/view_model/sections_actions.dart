import '../../domain/entities/section_definition.dart';

sealed class SectionsActions {}

class LoadSections extends SectionsActions {}

/// Debug-only: create or update one section's metadata.
class SaveSection extends SectionsActions {
  SaveSection(this.section);
  final SectionDefinition section;
}

/// Debug-only: persist a whole reordered list in one write.
class SaveAllSections extends SectionsActions {
  SaveAllSections(this.sections);
  final List<SectionDefinition> sections;
}

/// Debug-only: only custom sections can be removed; built-ins are hidden.
class DeleteCustomSection extends SectionsActions {
  DeleteCustomSection(this.id);
  final String id;
}
