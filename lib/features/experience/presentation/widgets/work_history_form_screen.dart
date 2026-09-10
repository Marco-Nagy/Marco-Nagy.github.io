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
import '../../../portfolio_content/domain/entities/work_history_entry.dart';

/// Debug-mode add/edit screen for one role in the experience timeline.
class WorkHistoryFormScreen extends StatefulWidget {
  const WorkHistoryFormScreen({this.entry, super.key});

  /// Null when adding.
  final WorkHistoryEntry? entry;

  static Future<WorkHistoryEntry?> open(
    BuildContext context, {
    WorkHistoryEntry? entry,
  }) {
    return AdminFormScreen.open<WorkHistoryEntry>(
      context,
      WorkHistoryFormScreen(entry: entry),
    );
  }

  @override
  State<WorkHistoryFormScreen> createState() => _WorkHistoryFormScreenState();
}

class _WorkHistoryFormScreenState extends State<WorkHistoryFormScreen> {
  late final String _id = widget.entry?.id ?? IdGenerator.next('work');

  late final TextEditingController _company;
  late final TextEditingController _roleEn;
  late final TextEditingController _roleAr;
  late final TextEditingController _startDate;
  late final TextEditingController _endDate;
  late final TextEditingController _locationEn;
  late final TextEditingController _locationAr;
  late final TextEditingController _bulletsEn;
  late final TextEditingController _bulletsAr;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;

    _company = TextEditingController(text: entry?.company ?? '');
    _roleEn = TextEditingController(text: entry?.role ?? '');
    _roleAr = TextEditingController(text: entry?.roleAr ?? '');
    _startDate = TextEditingController(text: entry?.startDate ?? '');
    _endDate = TextEditingController(text: entry?.endDate ?? '');
    _locationEn = TextEditingController(text: entry?.location ?? '');
    _locationAr = TextEditingController(text: entry?.locationAr ?? '');
    _bulletsEn = TextEditingController(
      text: TextListConverter.toText(entry?.bullets ?? <String>[]),
    );
    _bulletsAr = TextEditingController(
      text: TextListConverter.toText(entry?.bulletsAr ?? <String>[]),
    );
  }

  @override
  void dispose() {
    _company.dispose();
    _roleEn.dispose();
    _roleAr.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _locationEn.dispose();
    _locationAr.dispose();
    _bulletsEn.dispose();
    _bulletsAr.dispose();
    super.dispose();
  }

  void _submit() {
    final base = widget.entry ?? WorkHistoryEntry(id: _id, company: '');

    context.pop<WorkHistoryEntry>(
      base.copyWith(
        company: _company.text.trim(),
        role: _roleEn.text.trim(),
        roleAr: _roleAr.text.trim(),
        startDate: _startDate.text.trim(),
        // Deliberately not defaulted to anything: empty end date is what
        // WorkHistoryEntry.isCurrent reads as "present".
        endDate: _endDate.text.trim(),
        location: _locationEn.text.trim(),
        locationAr: _locationAr.text.trim(),
        bullets: TextListConverter.toList(_bulletsEn.text),
        bulletsAr: TextListConverter.toList(_bulletsAr.text),
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      UnderlineTextField(
        label: context.translate(LangKeys.fieldCompany),
        controller: _company,
        validator: (value) => Validators.required(context, value),
        textInputAction: TextInputAction.next,
      ),
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldRoleEn),
        labelAr: context.translate(LangKeys.fieldRoleAr),
        controllerEn: _roleEn,
        controllerAr: _roleAr,
      ),
      // Free text in MM/YYYY, matching the entity: the timeline prints these
      // verbatim, so a date picker would only add a format this app then has
      // to translate back.
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: UnderlineTextField(
              label: context.translate(LangKeys.fieldStartDate),
              controller: _startDate,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: UnderlineTextField(
              label: context.translate(LangKeys.fieldEndDate),
              controller: _endDate,
              textInputAction: TextInputAction.next,
            ),
          ),
        ],
      ),
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldLocationEn),
        labelAr: context.translate(LangKeys.fieldLocationAr),
        controllerEn: _locationEn,
        controllerAr: _locationAr,
      ),
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldBulletsEn),
        labelAr: context.translate(LangKeys.fieldBulletsAr),
        controllerEn: _bulletsEn,
        controllerAr: _bulletsAr,
        maxLines: 6,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormScreen(
      title: context.translate(
        widget.entry == null
            ? LangKeys.formAddExperience
            : LangKeys.formEditExperience,
      ),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}
