import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/widgets/admin/admin_form_sheet.dart';
import '../../../../core/widgets/admin/bilingual_field_pair.dart';
import '../../domain/entities/section_definition.dart';

/// Renames one section.
///
/// Rename only — visibility is a switch on the row that opens this, and order
/// belongs to the drag-and-drop reorder in Phase 5. A sheet rather than a
/// screen because two fields do not earn a page.
///
/// The title it edits is the *same* string the nav link and the section
/// heading both read, which is the point: they cannot drift apart because
/// there is only one of them.
class SectionFormSheet extends StatefulWidget {
  const SectionFormSheet({required this.section, super.key});

  final SectionDefinition section;

  static Future<SectionDefinition?> open(
    BuildContext context, {
    required SectionDefinition section,
  }) {
    return AdminFormSheet.show<SectionDefinition>(
      context,
      SectionFormSheet(section: section),
    );
  }

  @override
  State<SectionFormSheet> createState() => _SectionFormSheetState();
}

class _SectionFormSheetState extends State<SectionFormSheet> {
  late final _titleEn = TextEditingController(text: widget.section.titleEn);
  late final _titleAr = TextEditingController(text: widget.section.titleAr);

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    super.dispose();
  }

  void _submit() {
    // No validator on the English title: a section whose title is blank still
    // renders — the nav link goes empty and the heading disappears, which is a
    // legitimate way to run a section without a heading.
    context.pop<SectionDefinition>(
      widget.section.copyWith(
        titleEn: _titleEn.text.trim(),
        titleAr: _titleAr.text.trim(),
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldSectionTitleEn),
        labelAr: context.translate(LangKeys.fieldSectionTitleAr),
        controllerEn: _titleEn,
        controllerAr: _titleAr,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormSheet(
      title: context.translate(LangKeys.formEditSection),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}
