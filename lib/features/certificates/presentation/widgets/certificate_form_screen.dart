import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/admin/admin_form_screen.dart';
import '../../../../core/widgets/admin/bilingual_field_pair.dart';
import '../../../../core/widgets/admin/url_upload_field.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../portfolio_content/domain/entities/certificate.dart';

/// Debug-mode add/edit screen for one certificate.
///
/// Everything not claimed by a field here rides through untouched on
/// `copyWith`, so a field added to [Certificate] later is preserved by this
/// form rather than reset to its default the next time a certificate is saved.
class CertificateFormScreen extends StatefulWidget {
  const CertificateFormScreen({this.certificate, super.key});

  /// Null when adding.
  final Certificate? certificate;

  static Future<Certificate?> open(
    BuildContext context, {
    Certificate? certificate,
  }) {
    return AdminFormScreen.open<Certificate>(
      context,
      CertificateFormScreen(certificate: certificate),
    );
  }

  @override
  State<CertificateFormScreen> createState() => _CertificateFormScreenState();
}

class _CertificateFormScreenState extends State<CertificateFormScreen> {
  /// Resolved once, so a rebuild never hands the same new record a second id.
  late final String _id =
      widget.certificate?.id ?? IdGenerator.next('certificate');

  late final TextEditingController _titleEn;
  late final TextEditingController _titleAr;
  late final TextEditingController _providerEn;
  late final TextEditingController _providerAr;
  late final TextEditingController _year;
  late final TextEditingController _locationEn;
  late final TextEditingController _locationAr;
  late final TextEditingController _imageAsset;

  @override
  void initState() {
    super.initState();
    final certificate = widget.certificate;

    _titleEn = TextEditingController(text: certificate?.title ?? '');
    _titleAr = TextEditingController(text: certificate?.titleAr ?? '');
    _providerEn = TextEditingController(text: certificate?.provider ?? '');
    _providerAr = TextEditingController(text: certificate?.providerAr ?? '');
    _year = TextEditingController(text: certificate?.year ?? '');
    _locationEn = TextEditingController(text: certificate?.location ?? '');
    _locationAr = TextEditingController(text: certificate?.locationAr ?? '');
    _imageAsset = TextEditingController(text: certificate?.imageAsset ?? '');
  }

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _providerEn.dispose();
    _providerAr.dispose();
    _year.dispose();
    _locationEn.dispose();
    _locationAr.dispose();
    _imageAsset.dispose();
    super.dispose();
  }

  void _submit() {
    final base = widget.certificate ?? Certificate(id: _id, title: '');

    context.pop<Certificate>(
      base.copyWith(
        title: _titleEn.text.trim(),
        titleAr: _titleAr.text.trim(),
        provider: _providerEn.text.trim(),
        providerAr: _providerAr.text.trim(),
        year: _year.text.trim(),
        location: _locationEn.text.trim(),
        locationAr: _locationAr.text.trim(),
        imageAsset: _imageAsset.text.trim(),
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldTitleEn),
        labelAr: context.translate(LangKeys.fieldTitleAr),
        controllerEn: _titleEn,
        controllerAr: _titleAr,
        validator: (value) => Validators.required(context, value),
      ),
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldProviderEn),
        labelAr: context.translate(LangKeys.fieldProviderAr),
        controllerEn: _providerEn,
        controllerAr: _providerAr,
      ),
      // Free text, not a number: a certificate's year is sometimes a range
      // ("2022–2023") or a month, and parsing it would only reject those.
      UnderlineTextField(
        label: context.translate(LangKeys.fieldYear),
        controller: _year,
        textInputAction: TextInputAction.next,
      ),
      BilingualFieldPair(
        labelEn: context.translate(LangKeys.fieldLocationEn),
        labelAr: context.translate(LangKeys.fieldLocationAr),
        controllerEn: _locationEn,
        controllerAr: _locationAr,
      ),
      // Still a plain String on the entity rather than a full ImageRef —
      // widening it is a schema change this does not need, because
      // `ImageRef.fromSource` reads an uploaded Cloudinary URL out of the
      // same field a bundled `assets/...` path used to live in.
      UrlUploadField.image(
        label: context.translate(LangKeys.fieldImageAsset),
        controller: _imageAsset,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormScreen(
      title: context.translate(
        widget.certificate == null
            ? LangKeys.formAddCertificate
            : LangKeys.formEditCertificate,
      ),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}
