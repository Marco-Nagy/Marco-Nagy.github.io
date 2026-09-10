import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/admin/admin_form_screen.dart';
import '../../../../core/widgets/admin/bilingual_field_pair.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../portfolio_content/domain/entities/pricing_package.dart';

/// Debug-mode add/edit screen for one base package (MVP / Medium / Advanced).
class PricingPackageFormScreen extends StatefulWidget {
  const PricingPackageFormScreen({this.package, super.key});

  /// Null when adding.
  final PricingPackage? package;

  static Future<PricingPackage?> open(
    BuildContext context, {
    PricingPackage? package,
  }) {
    return AdminFormScreen.open<PricingPackage>(
      context,
      PricingPackageFormScreen(package: package),
    );
  }

  @override
  State<PricingPackageFormScreen> createState() =>
      _PricingPackageFormScreenState();
}

class _PricingPackageFormScreenState extends State<PricingPackageFormScreen> {
  late final String _id = widget.package?.id ?? IdGenerator.next('package');

  late final TextEditingController _nameEn;
  late final TextEditingController _nameAr;
  late final TextEditingController _basePrice;
  late final TextEditingController _timelineEn;
  late final TextEditingController _timelineAr;
  late final TextEditingController _descriptionEn;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _order;

  @override
  void initState() {
    super.initState();
    final package = widget.package;

    _nameEn = TextEditingController(text: package?.name ?? '');
    _nameAr = TextEditingController(text: package?.nameAr ?? '');
    _basePrice = TextEditingController(text: '${package?.basePrice ?? 0}');
    _timelineEn = TextEditingController(text: package?.timelineLabel ?? '');
    _timelineAr = TextEditingController(text: package?.timelineLabelAr ?? '');
    _descriptionEn = TextEditingController(text: package?.description ?? '');
    _descriptionAr = TextEditingController(text: package?.descriptionAr ?? '');
    _order = TextEditingController(text: '${package?.order ?? 0}');
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _basePrice.dispose();
    _timelineEn.dispose();
    _timelineAr.dispose();
    _descriptionEn.dispose();
    _descriptionAr.dispose();
    _order.dispose();
    super.dispose();
  }

  void _submit() {
    final base = widget.package ?? PricingPackage(id: _id, name: '');

    context.pop<PricingPackage>(
      base.copyWith(
        name: _nameEn.text.trim(),
        nameAr: _nameAr.text.trim(),
        // int, not double: the quote arithmetic is whole units throughout, and
        // a parsed 1200.5 would round differently in the summary than on the
        // card.
        basePrice: int.tryParse(_basePrice.text.trim()) ?? base.basePrice,
        timelineLabel: _timelineEn.text.trim(),
        timelineLabelAr: _timelineAr.text.trim(),
        description: _descriptionEn.text.trim(),
        descriptionAr: _descriptionAr.text.trim(),
        order: int.tryParse(_order.text.trim()) ?? base.order,
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
      UnderlineTextField(
        label: context.translate(LangKeys.fieldBasePrice),
        controller: _basePrice,
        keyboardType: TextInputType.number,
        validator: (value) => Validators.number(context, value),
      ),
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldTimelineEn),
        labelAr: context.translate(LangKeys.fieldTimelineAr),
        controllerEn: _timelineEn,
        controllerAr: _timelineAr,
      ),
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldDescriptionEn),
        labelAr: context.translate(LangKeys.fieldDescriptionAr),
        controllerEn: _descriptionEn,
        controllerAr: _descriptionAr,
        maxLines: 3,
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
        widget.package == null
            ? LangKeys.formAddPackage
            : LangKeys.formEditPackage,
      ),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}
