import 'package:flutter/foundation.dart' show immutable;

import '../../domain/entities/skill_group_entity.dart';
import '../../domain/entities/tech_badge_entity.dart';

/// No `Loading` case: the hero orbit animates from the first frame, so an
/// empty list is the honest in-flight state rather than a spinner.
@immutable
sealed class SkillsState {
  const SkillsState();
}

class SkillsInitial extends SkillsState {
  const SkillsInitial();
}

class SkillsReady extends SkillsState {
  const SkillsReady({required this.groups, required this.badges});
  final List<SkillGroupEntity> groups;
  final List<TechBadgeEntity> badges;
}

class SkillsFailure extends SkillsState {
  const SkillsFailure(this.message);
  final String message;
}
