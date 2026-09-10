import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/text_list_converter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/admin/admin_form_screen.dart';
import '../../../../core/widgets/admin/bilingual_field_pair.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../domain/entities/skill_group_entity.dart';

/// Debug-mode add/edit screen for one labelled group of skill chips.
///
/// Only the group label is bilingual. The skills themselves are proper nouns —
/// Bloc, SQLite, GitHub Actions — so they are one list, not two, which is the
/// rule [SkillGroupEntity] already states and the About block already renders.
class SkillGroupFormScreen extends StatefulWidget {
  const SkillGroupFormScreen({this.group, super.key});

  /// Null when adding.
  final SkillGroupEntity? group;

  static Future<SkillGroupEntity?> open(
    BuildContext context, {
    SkillGroupEntity? group,
  }) {
    return AdminFormScreen.open<SkillGroupEntity>(
      context,
      SkillGroupFormScreen(group: group),
    );
  }

  @override
  State<SkillGroupFormScreen> createState() => _SkillGroupFormScreenState();
}

class _SkillGroupFormScreenState extends State<SkillGroupFormScreen> {
  late final String _id = widget.group?.id ?? IdGenerator.next('skill_group');

  late final _labelEn = TextEditingController(
    text: widget.group?.labelEn ?? '',
  );
  late final _labelAr = TextEditingController(
    text: widget.group?.labelAr ?? '',
  );
  late final _skills = TextEditingController(
    text: TextListConverter.toText(widget.group?.skills ?? <String>[]),
  );
  late final _order = TextEditingController(
    text: '${widget.group?.order ?? 0}',
  );

  @override
  void dispose() {
    _labelEn.dispose();
    _labelAr.dispose();
    _skills.dispose();
    _order.dispose();
    super.dispose();
  }

  void _submit() {
    final base = widget.group ?? SkillGroupEntity(id: _id);

    context.pop<SkillGroupEntity>(
      base.copyWith(
        labelEn: _labelEn.text.trim(),
        labelAr: _labelAr.text.trim(),
        skills: TextListConverter.toList(_skills.text),
        order: int.tryParse(_order.text.trim()) ?? base.order,
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldSkillGroupLabelEn),
        labelAr: context.translate(LangKeys.fieldSkillGroupLabelAr),
        controllerEn: _labelEn,
        controllerAr: _labelAr,
        validator: (value) => Validators.required(context, value),
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldSkillNames),
        controller: _skills,
        maxLines: 8,
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
    return AdminFormScreen(
      title: context.translate(
        widget.group == null
            ? LangKeys.formAddSkillGroup
            : LangKeys.formEditSkillGroup,
      ),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}
