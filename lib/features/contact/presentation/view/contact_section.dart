import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../../../../core/utils/responsive/app_breakpoints.dart';
import '../../../../core/utils/url_opener.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/common/app_snack_bar.dart';
import '../../../../core/widgets/common/content_container.dart';
import '../../../../core/widgets/common/pill_button.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../core/widgets/motion/reveal_on_scroll.dart';
import '../../../../core/widgets/section/section_divider_header.dart';
import '../widgets/contact_links.dart';

/// "Get in touch." with underline-only fields.
///
/// There is no backend, so submitting composes a mailto: with the message
/// prefilled rather than pretending to POST somewhere.
class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final opened = await UrlOpener.open(
      context.siteLinks.mailto(
        subject: _subject.text.trim(),
        body:
            '${_message.text.trim()}\n\n'
            '${_name.text.trim()}\n${_email.text.trim()}',
      ),
    );
    if (!mounted) return;

    AppSnackBar.show(
      context,
      context.translate(opened ? LangKeys.contactSent : LangKeys.commonError),
      kind: opened ? SnackKind.success : SnackKind.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionDividerHeader(
          title: context.sectionTitle(BuiltInSectionIds.contact),
        ),
        ContentContainer(
          child: context.isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: RevealOnScroll(child: _buildForm(context)),
                    ),
                    SizedBox(width: 48.w),
                    Expanded(
                      flex: 4,
                      child: RevealOnScroll(
                        delay: Motion.stagger,
                        child: const ContactLinks(),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RevealOnScroll(child: _buildForm(context)),
                    SizedBox(height: 48.h),
                    const RevealOnScroll(
                      delay: Motion.stagger,
                      child: ContactLinks(),
                    ),
                  ],
                ),
        ),
        SizedBox(height: 96.h),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final colors = context.colors;
    final site = context.site;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.localized(site.contactTitleEn, site.contactTitleAr),
          style: (context.isMobile ? MyFonts.display36 : MyFonts.display48)
              .copyWith(color: colors.onNavy),
        ),
        SizedBox(height: 14.h),
        Text(
          context.localized(site.contactSubtitleEn, site.contactSubtitleAr),
          style: MyFonts.regular16.copyWith(color: colors.onNavyMuted),
        ),
        SizedBox(height: 40.h),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              UnderlineTextField(
                label: context.translate(LangKeys.contactName),
                controller: _name,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(context, value),
              ),
              UnderlineTextField(
                label: context.translate(LangKeys.contactEmail),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.email(context, value),
              ),
              UnderlineTextField(
                label: context.translate(LangKeys.contactSubject),
                controller: _subject,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(context, value),
              ),
              UnderlineTextField(
                label: context.translate(LangKeys.contactMessage),
                controller: _message,
                maxLines: 4,
                validator: (value) => Validators.message(context, value),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        PillButton(
          label: context.translate(LangKeys.contactSend),
          onPressed: _submit,
        ),
      ],
    );
  }
}
