import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/widgets/admin/admin_confirm_dialog.dart';
import '../../../../core/widgets/admin/admin_list_screen.dart';
import '../../../../core/widgets/admin/admin_sub_list.dart';
import '../../../../core/widgets/common/app_snack_bar.dart';
import '../../domain/entities/skill_group_entity.dart';
import '../view_model/skills_actions.dart';
import '../view_model/skills_states.dart';
import '../view_model/skills_view_model.dart';
import 'skill_group_form_screen.dart';

/// Manages the grouped skill chips rendered in the About section.
///
/// Reached from the [AdminFab] rather than inline under the About block, so
/// the whole set is editable from anywhere on the site instead of only from
/// the one page that happens to render it.
class SkillsManagerScreen extends StatelessWidget {
  const SkillsManagerScreen({super.key});

  static Future<void> open(BuildContext context) =>
      AdminListScreen.open(context, const SkillsManagerScreen());

  @override
  Widget build(BuildContext context) {
    return AdminListScreen(
      title: context.translate(LangKeys.adminSkills),
      // The cubit is app-wide, above MaterialApp, so a pushed route still
      // finds it — no provider of its own is needed here.
      body: BlocBuilder<SkillsCubit, SkillsState>(
        builder: (context, _) {
          final cubit = context.read<SkillsCubit>();
          final groups = cubit.orderedGroups;

          return AdminSubList(
            label: context.translate(LangKeys.adminSkills),
            addLabel: context.translate(LangKeys.formAddSkillGroup),
            emptyLabel: context.translate(LangKeys.skillsEmpty),
            items: <AdminSubListItem>[
              for (final group in groups)
                AdminSubListItem(
                  title: context.localized(group.labelEn, group.labelAr),
                  subtitle: group.skills.isEmpty
                      ? context.translate(LangKeys.adminEmptyItem)
                      : group.skills.join(' · '),
                  onEdit: () => _editGroup(context, cubit, group),
                  onDelete: () => _deleteGroup(context, cubit, group.id),
                ),
            ],
            onAdd: () => _editGroup(context, cubit, null),
          );
        },
      ),
    );
  }
}

/// The cubit is passed in rather than read after the await: this screen
/// rebuilds on every save, so the context that opened the form can be gone.
Future<void> _editGroup(
  BuildContext context,
  SkillsCubit cubit,
  SkillGroupEntity? group,
) async {
  final built = await SkillGroupFormScreen.open(context, group: group);
  if (built == null || !context.mounted) return;

  cubit.doAction(SaveSkillGroup(built));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminSaved),
    kind: SnackKind.success,
  );
}

Future<void> _deleteGroup(
  BuildContext context,
  SkillsCubit cubit,
  String id,
) async {
  final confirmed = await AdminConfirmDialog.show(context);
  if (!confirmed || !context.mounted) return;

  cubit.doAction(DeleteSkillGroup(id));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminDeleted),
    kind: SnackKind.success,
  );
}
