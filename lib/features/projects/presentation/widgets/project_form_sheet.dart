import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/text_list_converter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/admin/admin_form_sheet.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../portfolio_content/domain/entities/image_ref.dart';
import '../../../portfolio_content/domain/entities/personal_project.dart';

/// Debug-mode add/edit form for one project.
///
/// Deliberately edits only the flat fields. `panels`, `showcaseBackground` and
/// anything else the showcase composer owns are carried through untouched by
/// building the result with `copyWith` on the project being edited.
class ProjectFormSheet extends StatefulWidget {
  const ProjectFormSheet({this.project, super.key});

  /// Null when adding.
  final PersonalProject? project;

  /// Opens the sheet and resolves to the built project, or null if dismissed.
  ///
  /// The route is typed `Object?` because [AdminFormSheet] pops `false` on
  /// cancel — typing it `PersonalProject` would throw on that pop.
  static Future<PersonalProject?> open(
    BuildContext context, {
    PersonalProject? project,
  }) async {
    final result = await AdminFormSheet.show<Object?>(
      context,
      ProjectFormSheet(project: project),
    );
    return result is PersonalProject ? result : null;
  }

  @override
  State<ProjectFormSheet> createState() => _ProjectFormSheetState();
}

class _ProjectFormSheetState extends State<ProjectFormSheet> {
  /// Resolved once, so a rebuild never hands the same new project a second id.
  late final String _id = widget.project?.id ?? IdGenerator.next('project');

  late final TextEditingController _titleEn;
  late final TextEditingController _titleAr;
  late final TextEditingController _categoryEn;
  late final TextEditingController _categoryAr;
  late final TextEditingController _descriptionEn;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _featuresEn;
  late final TextEditingController _featuresAr;
  late final TextEditingController _cover;
  late final TextEditingController _accentHex;
  late final TextEditingController _order;

  @override
  void initState() {
    super.initState();
    final project = widget.project;

    _titleEn = TextEditingController(text: project?.title ?? '');
    _titleAr = TextEditingController(text: project?.titleAr ?? '');
    _categoryEn = TextEditingController(text: project?.category ?? '');
    _categoryAr = TextEditingController(text: project?.categoryAr ?? '');
    _descriptionEn = TextEditingController(text: project?.description ?? '');
    _descriptionAr = TextEditingController(text: project?.descriptionAr ?? '');
    _featuresEn = TextEditingController(
      text: TextListConverter.toText(project?.features ?? <String>[]),
    );
    _featuresAr = TextEditingController(
      text: TextListConverter.toText(project?.featuresAr ?? <String>[]),
    );
    _cover = TextEditingController(text: project?.cover.value ?? '');
    _accentHex = TextEditingController(text: project?.accentHex ?? '');
    _order = TextEditingController(text: '${project?.order ?? 0}');
  }

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _categoryEn.dispose();
    _categoryAr.dispose();
    _descriptionEn.dispose();
    _descriptionAr.dispose();
    _featuresEn.dispose();
    _featuresAr.dispose();
    _cover.dispose();
    _accentHex.dispose();
    _order.dispose();
    super.dispose();
  }

  void _submit() {
    final base = widget.project ?? PersonalProject(id: _id, title: '');
    final coverPath = _cover.text.trim();
    final hex = _accentHex.text.trim().replaceFirst('#', '').toUpperCase();

    context.pop<PersonalProject>(
      base.copyWith(
        title: _titleEn.text.trim(),
        titleAr: _titleAr.text.trim(),
        category: _categoryEn.text.trim(),
        categoryAr: _categoryAr.text.trim(),
        description: _descriptionEn.text.trim(),
        descriptionAr: _descriptionAr.text.trim(),
        features: TextListConverter.toList(_featuresEn.text),
        featuresAr: TextListConverter.toList(_featuresAr.text),
        // An untouched path keeps whatever kind it already had; only a real
        // edit reverts it to an asset path.
        cover: coverPath == base.cover.value
            ? base.cover
            : ImageRef.asset(coverPath),
        accentHex: hex.length == 6 ? hex : base.accentHex,
        order: int.tryParse(_order.text.trim()) ?? base.order,
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      UnderlineTextField(
        label: context.translate(LangKeys.fieldTitleEn),
        controller: _titleEn,
        validator: (value) => Validators.required(context, value),
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldTitleAr),
        controller: _titleAr,
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldCategoryEn),
        controller: _categoryEn,
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldCategoryAr),
        controller: _categoryAr,
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldDescriptionEn),
        controller: _descriptionEn,
        maxLines: 3,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldDescriptionAr),
        controller: _descriptionAr,
        maxLines: 3,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldFeaturesEn),
        controller: _featuresEn,
        maxLines: 6,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldFeaturesAr),
        controller: _featuresAr,
        maxLines: 6,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldCoverImage),
        controller: _cover,
        hint: 'assets/images/projects/cover.png',
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldAccentColor),
        controller: _accentHex,
        hint: '4CC9F0',
        textInputAction: TextInputAction.next,
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldOrder),
        controller: _order,
        keyboardType: TextInputType.number,
        validator: (value) => Validators.number(context, value),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormSheet(
      title: context.translate(
        widget.project == null
            ? LangKeys.formAddProject
            : LangKeys.formEditProject,
      ),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}
