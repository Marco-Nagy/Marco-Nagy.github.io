import '../../../portfolio_content/domain/entities/work_history_entry.dart';

sealed class ExperienceActions {}

class LoadWorkHistory extends ExperienceActions {}

/// Debug-only: create or update an entry.
class SaveWorkHistory extends ExperienceActions {
  SaveWorkHistory(this.entry);
  final WorkHistoryEntry entry;
}

/// Debug-only: remove an entry.
class DeleteWorkHistory extends ExperienceActions {
  DeleteWorkHistory(this.id);
  final String id;
}

/// Debug-only: persist a whole reordered list in one write.
class ReorderWorkHistory extends ExperienceActions {
  ReorderWorkHistory(this.entries);
  final List<WorkHistoryEntry> entries;
}
