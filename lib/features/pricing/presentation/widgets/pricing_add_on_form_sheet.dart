import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/admin/admin_form_sheet.dart';
import '../../../../core/widgets/admin/admin_switch_field.dart';
import '../../../../core/widgets/admin/bilingual_field_pair.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../portfolio_content/domain/entities/pricing_add_on.dart';

/// Debug-mode add/edit sheet for one pricing add-on.
///
/// A sheet rather than a page, unlike the package form beside it: an add-on is
/// a handful of short fields with no sub-lists and no media, so it opens and
/// closes in a single save — which is what a sheet is for.
class PricingAddOnFormSheet extends StatefulWidget {
  const PricingAddOnFormSheet({this.addOn, super.key});

  /// Null when adding.
  final PricingAddOn? addOn;

  static Future<PricingAddOn?> open(
    BuildContext context, {
    PricingAddOn? addOn,
  }) {
    return AdminFormSheet.show<PricingAddOn>(
      context,
      PricingAddOnFormSheet(addOn: addOn),
    );
  }

  @override
  State<PricingAddOnFormSheet> createState() => _PricingAddOnFormSheetState();
}

class _PricingAddOnFormSheetState extends State<PricingAddOnFormSheet> {
  late final String _id = widget.addOn?.id ?? IdGenerator.next('add_on');

  late final TextEditingController _nameEn;
  late final TextEditingController _nameAr;
  late final TextEditingController _unitPrice;
  late final TextEditingController _unitTimeDays;
  late final TextEditingController _categoryEn;
  late final TextEditingController _categoryAr;
  late bool _hasCounter;

  @override
  void initState() {
    super.initState();
    final addOn = widget.addOn;

    _nameEn = TextEditingController(text: addOn?.name ?? '');
    _nameAr = TextEditingController(text: addOn?.nameAr ?? '');
    _unitPrice = TextEditingController(text: '${addOn?.unitPrice ?? 0}');
    _unitTimeDays = TextEditingController(text: '${addOn?.unitTimeDays ?? 0}');
    _categoryEn = TextEditingController(text: addOn?.category ?? '');
    _categoryAr = TextEditingController(text: addOn?.categoryAr ?? '');
    _hasCounter = addOn?.hasCounter ?? false;
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _unitPrice.dispose();
    _unitTimeDays.dispose();
    _categoryEn.dispose();
    _categoryAr.dispose();
    super.dispose();
  }

  void _submit() {
    final base = widget.addOn ?? PricingAddOn(id: _id, name: '');

    context.pop<PricingAddOn>(
      base.copyWith(
        name: _nameEn.text.trim(),
        nameAr: _nameAr.text.trim(),
        unitPrice: int.tryParse(_unitPrice.text.trim()) ?? base.unitPrice,
        unitTimeDays:
            int.tryParse(_unitTimeDays.text.trim()) ?? base.unitTimeDays,
        hasCounter: _hasCounter,
        // The category is the grouping heading in the add-on list, not a free
        // label: add-ons sharing category text land under one heading, and
        // blank ones sit ungrouped above the first heading.
        category: _categoryEn.text.trim(),
        categoryAr: _categoryAr.text.trim(),
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldNameEn),
        labelAr: context.translate(LangKeys.fieldNameAr),
        controllerEn: _nameEn,
        controllerAr: _nameAr,
        validator: (value) => Validators.required(context, value),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: UnderlineTextField(
              label: context.translate(LangKeys.fieldUnitPrice),
              controller: _unitPrice,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.number(context, value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: UnderlineTextField(
              label: context.translate(LangKeys.fieldUnitTimeDays),
              controller: _unitTimeDays,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.number(context, value),
            ),
          ),
        ],
      ),
      AdminSwitchField(
        label: context.translate(LangKeys.fieldHasCounter),
        value: _hasCounter,
        onChanged: (value) => setState(() => _hasCounter = value),
      ),
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldCategoryEn),
        labelAr: context.translate(LangKeys.fieldCategoryAr),
        controllerEn: _categoryEn,
        controllerAr: _categoryAr,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormSheet(
      title: context.translate(
        widget.addOn == null ? LangKeys.formAddAddOn : LangKeys.formEditAddOn,
      ),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}
