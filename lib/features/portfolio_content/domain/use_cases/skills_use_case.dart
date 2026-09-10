import 'package:injectable/injectable.dart';

import '../../../../core/common/data_result.dart';
import '../entities/skill_group_entity.dart';
import '../entities/tech_badge_entity.dart';
import '../repositories/portfolio_repo.dart';

@injectable
class SkillsUseCase {
  const SkillsUseCase(this._repo);

  final PortfolioRepo _repo;

  Future<DataResult<List<SkillGroupEntity>>> getGroups() =>
      _repo.getSkillGroups();

  Future<DataResult<List<SkillGroupEntity>>> upsertGroup(
    SkillGroupEntity group,
  ) => _repo.upsertSkillGroup(group);

  /// Persists a whole reordered list in one write.
  Future<DataResult<List<SkillGroupEntity>>> saveAllGroups(
    List<SkillGroupEntity> groups,
  ) => _repo.saveSkillGroups(groups);

  Future<DataResult<List<SkillGroupEntity>>> deleteGroup(String id) =>
      _repo.deleteSkillGroup(id);

  Future<DataResult<List<TechBadgeEntity>>> getBadges() =>
      _repo.getTechBadges();

  Future<DataResult<List<TechBadgeEntity>>> upsertBadge(
    TechBadgeEntity badge,
  ) => _repo.upsertTechBadge(badge);

  Future<DataResult<List<TechBadgeEntity>>> deleteBadge(String id) =>
      _repo.deleteTechBadge(id);
}
