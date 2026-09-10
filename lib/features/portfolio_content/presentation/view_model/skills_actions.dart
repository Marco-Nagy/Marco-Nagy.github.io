import '../../domain/entities/skill_group_entity.dart';
import '../../domain/entities/tech_badge_entity.dart';

sealed class SkillsActions {}

/// Reads both collections — the About skills block and the hero orbit are
/// always on screen together on a single-page site.
class LoadSkills extends SkillsActions {}

class SaveSkillGroup extends SkillsActions {
  SaveSkillGroup(this.group);
  final SkillGroupEntity group;
}

class DeleteSkillGroup extends SkillsActions {
  DeleteSkillGroup(this.id);
  final String id;
}

class SaveTechBadge extends SkillsActions {
  SaveTechBadge(this.badge);
  final TechBadgeEntity badge;
}

class DeleteTechBadge extends SkillsActions {
  DeleteTechBadge(this.id);
  final String id;
}
