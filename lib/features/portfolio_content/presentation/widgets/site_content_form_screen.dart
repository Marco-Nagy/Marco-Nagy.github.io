import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/text_list_converter.dart';
import '../../../../core/widgets/admin/admin_form_screen.dart';
import '../../../../core/widgets/admin/bilingual_field_pair.dart';
import '../../../../core/widgets/admin/crop_photo_dialog.dart';
import '../../../../core/widgets/admin/profile_photo_field.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../domain/entities/image_ref.dart';
import '../../domain/entities/site_content.dart';

/// Debug-mode editor for the whole [SiteContent] singleton — every visitor-
/// facing string that is not attached to a list record.
///
/// Grouped into collapsible sections rather than one 43-field column, because
/// this is the only form in the admin whose fields have nothing structural in
/// common: the monogram and the footer availability line share a screen only
/// because they share a document.
///
/// The one thing this form does *not* reach is the hero orbit badges. Those
/// read `TechBrandMarks.all`, a build-time catalogue — a badge cannot exist
/// without its SVG shipping in `pubspec.yaml`, so its list is configuration
/// rather than content. See the Phase 3 note in the migration plan.
class SiteContentFormScreen extends StatefulWidget {
  const SiteContentFormScreen({required this.content, super.key});

  /// Never null: [SiteContent] is a singleton with defaults, so there is no
  /// "adding" case here — only editing what is already there.
  final SiteContent content;

  static Future<SiteContent?> open(
    BuildContext context, {
    required SiteContent content,
  }) {
    return AdminFormScreen.open<SiteContent>(
      context,
      SiteContentFormScreen(content: content),
    );
  }

  @override
  State<SiteContentFormScreen> createState() => _SiteContentFormScreenState();
}

class _SiteContentFormScreenState extends State<SiteContentFormScreen> {
  SiteContent get _c => widget.content;

  // Field initialisers rather than an initState block: 43 controllers make the
  // usual declare-then-assign pattern twice as long for no extra clarity, and
  // each line still names exactly what it reads.
  late final _fullNameEn = TextEditingController(text: _c.fullNameEn);
  late final _fullNameAr = TextEditingController(text: _c.fullNameAr);
  late final _roleEn = TextEditingController(text: _c.roleEn);
  late final _roleAr = TextEditingController(text: _c.roleAr);
  late final _monogram = TextEditingController(text: _c.monogram);
  late final _locationEn = TextEditingController(text: _c.locationEn);
  late final _locationAr = TextEditingController(text: _c.locationAr);

  /// Not a [TextEditingController]: [ProfilePhotoField] hands back a whole
  /// [ImageRef] from its pick-and-crop flow rather than text to parse.
  late ImageRef _profileImage = _c.profileImage;
  late ImageRef _aboutPhotoImage = _c.aboutPhotoImage;

  late final _email = TextEditingController(text: _c.email);
  late final _phone = TextEditingController(text: _c.phone);
  late final _gitHubUrl = TextEditingController(text: _c.gitHubUrl);
  late final _linkedInUrl = TextEditingController(text: _c.linkedInUrl);
  late final _hostedCvUrl = TextEditingController(text: _c.hostedCvUrl);

  late final _heroGreetingEn = TextEditingController(text: _c.heroGreetingEn);
  late final _heroGreetingAr = TextEditingController(text: _c.heroGreetingAr);
  late final _heroNameEn = TextEditingController(text: _c.heroNameEn);
  late final _heroNameAr = TextEditingController(text: _c.heroNameAr);
  late final _heroRoleEn = TextEditingController(text: _c.heroRoleEn);
  late final _heroRoleAr = TextEditingController(text: _c.heroRoleAr);
  late final _roleTagsEn = TextEditingController(
    text: TextListConverter.toText(_c.roleTagsEn),
  );
  late final _roleTagsAr = TextEditingController(
    text: TextListConverter.toText(_c.roleTagsAr),
  );

  late final _summaryEn = TextEditingController(text: _c.summaryEn);
  late final _summaryAr = TextEditingController(text: _c.summaryAr);
  late final _aboutLeadEn = TextEditingController(text: _c.aboutLeadEn);
  late final _aboutLeadAr = TextEditingController(text: _c.aboutLeadAr);
  late final _aboutStatementsEn = TextEditingController(
    text: TextListConverter.toText(_c.aboutStatementsEn),
  );
  late final _aboutStatementsAr = TextEditingController(
    text: TextListConverter.toText(_c.aboutStatementsAr),
  );

  late final _contactTitleEn = TextEditingController(text: _c.contactTitleEn);
  late final _contactTitleAr = TextEditingController(text: _c.contactTitleAr);
  late final _contactSubtitleEn = TextEditingController(
    text: _c.contactSubtitleEn,
  );
  late final _contactSubtitleAr = TextEditingController(
    text: _c.contactSubtitleAr,
  );

  late final _footerHeadlineEn = TextEditingController(
    text: _c.footerHeadlineEn,
  );
  late final _footerHeadlineAr = TextEditingController(
    text: _c.footerHeadlineAr,
  );
  late final _footerAvailabilityEn = TextEditingController(
    text: _c.footerAvailabilityEn,
  );
  late final _footerAvailabilityAr = TextEditingController(
    text: _c.footerAvailabilityAr,
  );

  late final _worksHeadlineEn = TextEditingController(
    text: _c.homeWorksHeadlineEn,
  );
  late final _worksHeadlineAr = TextEditingController(
    text: _c.homeWorksHeadlineAr,
  );
  late final _worksSubtitleEn = TextEditingController(
    text: _c.homeWorksSubtitleEn,
  );
  late final _worksSubtitleAr = TextEditingController(
    text: _c.homeWorksSubtitleAr,
  );
  late final _worksMoreLabelEn = TextEditingController(
    text: _c.homeWorksMoreLabelEn,
  );
  late final _worksMoreLabelAr = TextEditingController(
    text: _c.homeWorksMoreLabelAr,
  );
  late final _worksViewAllEn = TextEditingController(
    text: _c.homeWorksViewAllEn,
  );
  late final _worksViewAllAr = TextEditingController(
    text: _c.homeWorksViewAllAr,
  );

  List<TextEditingController> get _controllers => <TextEditingController>[
    _fullNameEn,
    _fullNameAr,
    _roleEn,
    _roleAr,
    _monogram,
    _locationEn,
    _locationAr,
    _email,
    _phone,
    _gitHubUrl,
    _linkedInUrl,
    _hostedCvUrl,
    _heroGreetingEn,
    _heroGreetingAr,
    _heroNameEn,
    _heroNameAr,
    _heroRoleEn,
    _heroRoleAr,
    _roleTagsEn,
    _roleTagsAr,
    _summaryEn,
    _summaryAr,
    _aboutLeadEn,
    _aboutLeadAr,
    _aboutStatementsEn,
    _aboutStatementsAr,
    _contactTitleEn,
    _contactTitleAr,
    _contactSubtitleEn,
    _contactSubtitleAr,
    _footerHeadlineEn,
    _footerHeadlineAr,
    _footerAvailabilityEn,
    _footerAvailabilityAr,
    _worksHeadlineEn,
    _worksHeadlineAr,
    _worksSubtitleEn,
    _worksSubtitleAr,
    _worksMoreLabelEn,
    _worksMoreLabelAr,
    _worksViewAllEn,
    _worksViewAllAr,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    // copyWith on the incoming content, not a fresh SiteContent: a field added
    // to the entity that this form has not grown a control for yet rides
    // through untouched instead of being reset to its default on every save.
    context.pop<SiteContent>(
      _c.copyWith(
        fullNameEn: _fullNameEn.text.trim(),
        fullNameAr: _fullNameAr.text.trim(),
        roleEn: _roleEn.text.trim(),
        roleAr: _roleAr.text.trim(),
        monogram: _monogram.text.trim(),
        locationEn: _locationEn.text.trim(),
        locationAr: _locationAr.text.trim(),
        profileImage: _profileImage,
        aboutPhotoImage: _aboutPhotoImage,
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        gitHubUrl: _gitHubUrl.text.trim(),
        linkedInUrl: _linkedInUrl.text.trim(),
        hostedCvUrl: _hostedCvUrl.text.trim(),
        heroGreetingEn: _heroGreetingEn.text.trim(),
        heroGreetingAr: _heroGreetingAr.text.trim(),
        heroNameEn: _heroNameEn.text.trim(),
        heroNameAr: _heroNameAr.text.trim(),
        heroRoleEn: _heroRoleEn.text.trim(),
        heroRoleAr: _heroRoleAr.text.trim(),
        roleTagsEn: TextListConverter.toList(_roleTagsEn.text),
        roleTagsAr: TextListConverter.toList(_roleTagsAr.text),
        summaryEn: _summaryEn.text.trim(),
        summaryAr: _summaryAr.text.trim(),
        aboutLeadEn: _aboutLeadEn.text.trim(),
        aboutLeadAr: _aboutLeadAr.text.trim(),
        aboutStatementsEn: TextListConverter.toList(_aboutStatementsEn.text),
        aboutStatementsAr: TextListConverter.toList(_aboutStatementsAr.text),
        contactTitleEn: _contactTitleEn.text.trim(),
        contactTitleAr: _contactTitleAr.text.trim(),
        contactSubtitleEn: _contactSubtitleEn.text.trim(),
        contactSubtitleAr: _contactSubtitleAr.text.trim(),
        footerHeadlineEn: _footerHeadlineEn.text.trim(),
        footerHeadlineAr: _footerHeadlineAr.text.trim(),
        footerAvailabilityEn: _footerAvailabilityEn.text.trim(),
        footerAvailabilityAr: _footerAvailabilityAr.text.trim(),
        homeWorksHeadlineEn: _worksHeadlineEn.text.trim(),
        homeWorksHeadlineAr: _worksHeadlineAr.text.trim(),
        homeWorksSubtitleEn: _worksSubtitleEn.text.trim(),
        homeWorksSubtitleAr: _worksSubtitleAr.text.trim(),
        homeWorksMoreLabelEn: _worksMoreLabelEn.text.trim(),
        homeWorksMoreLabelAr: _worksMoreLabelAr.text.trim(),
        homeWorksViewAllEn: _worksViewAllEn.text.trim(),
        homeWorksViewAllAr: _worksViewAllAr.text.trim(),
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    String t(String key) => context.translate(key);

    return <Widget>[
      _Group(
        title: t(LangKeys.groupIdentity),
        // Open on arrival so the screen does not read as six empty rows.
        initiallyExpanded: true,
        children: <Widget>[
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldFullNameEn),
            labelAr: t(LangKeys.fieldFullNameAr),
            controllerEn: _fullNameEn,
            controllerAr: _fullNameAr,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldRoleEn),
            labelAr: t(LangKeys.fieldRoleAr),
            controllerEn: _roleEn,
            controllerAr: _roleAr,
          ),
          UnderlineTextField(
            label: t(LangKeys.fieldMonogram),
            controller: _monogram,
            textInputAction: TextInputAction.next,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldLocationEn),
            labelAr: t(LangKeys.fieldLocationAr),
            controllerEn: _locationEn,
            controllerAr: _locationAr,
          ),
          // Pick-and-crop rather than MediaRefField's path/URL box: a headshot
          // only ever comes from a file on hand, and cropping it to the
          // circle it actually renders in (ClipOval on the hero) here means
          // what is previewed is what ships, not a guess from a raw path.
          ProfilePhotoField(
            label: t(LangKeys.fieldProfileImage),
            value: _profileImage,
            shape: PhotoCropShape.circle,
            onChanged: (image) => setState(() => _profileImage = image),
          ),
        ],
      ),
      _Group(
        title: t(LangKeys.groupHero),
        children: <Widget>[
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldHeroGreetingEn),
            labelAr: t(LangKeys.fieldHeroGreetingAr),
            controllerEn: _heroGreetingEn,
            controllerAr: _heroGreetingAr,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldHeroNameEn),
            labelAr: t(LangKeys.fieldHeroNameAr),
            controllerEn: _heroNameEn,
            controllerAr: _heroNameAr,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldHeroRoleEn),
            labelAr: t(LangKeys.fieldHeroRoleAr),
            controllerEn: _heroRoleEn,
            controllerAr: _heroRoleAr,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldRoleTagsEn),
            labelAr: t(LangKeys.fieldRoleTagsAr),
            controllerEn: _roleTagsEn,
            controllerAr: _roleTagsAr,
            maxLines: 4,
          ),
        ],
      ),
      _Group(
        title: t(LangKeys.groupAbout),
        children: <Widget>[
          // Falls back to the hero's photo at render time when unset
          // (`SiteContent.aboutPhoto`), but the form still edits the two
          // fields separately: About wants a square crop, Hero a circular
          // one, and they are not always the same source photo.
          ProfilePhotoField(
            label: t(LangKeys.fieldAboutPhoto),
            value: _aboutPhotoImage,
            shape: PhotoCropShape.square,
            onChanged: (image) => setState(() => _aboutPhotoImage = image),
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldAboutLeadEn),
            labelAr: t(LangKeys.fieldAboutLeadAr),
            controllerEn: _aboutLeadEn,
            controllerAr: _aboutLeadAr,
            maxLines: 2,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldAboutStatementsEn),
            labelAr: t(LangKeys.fieldAboutStatementsAr),
            controllerEn: _aboutStatementsEn,
            controllerAr: _aboutStatementsAr,
            maxLines: 6,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldSummaryEn),
            labelAr: t(LangKeys.fieldSummaryAr),
            controllerEn: _summaryEn,
            controllerAr: _summaryAr,
            maxLines: 5,
          ),
        ],
      ),
      _Group(
        title: t(LangKeys.groupContact),
        children: <Widget>[
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldContactTitleEn),
            labelAr: t(LangKeys.fieldContactTitleAr),
            controllerEn: _contactTitleEn,
            controllerAr: _contactTitleAr,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldContactSubtitleEn),
            labelAr: t(LangKeys.fieldContactSubtitleAr),
            controllerEn: _contactSubtitleEn,
            controllerAr: _contactSubtitleAr,
            maxLines: 3,
          ),
          UnderlineTextField(
            label: t(LangKeys.fieldEmail),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          UnderlineTextField(
            label: t(LangKeys.fieldPhone),
            controller: _phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          UnderlineTextField(
            label: t(LangKeys.fieldGithubUrl),
            controller: _gitHubUrl,
            textInputAction: TextInputAction.next,
          ),
          UnderlineTextField(
            label: t(LangKeys.fieldLinkedinUrl),
            controller: _linkedInUrl,
            textInputAction: TextInputAction.next,
          ),
          UnderlineTextField(
            label: t(LangKeys.fieldHostedCvUrl),
            controller: _hostedCvUrl,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
      _Group(
        title: t(LangKeys.groupFooter),
        children: <Widget>[
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldFooterHeadlineEn),
            labelAr: t(LangKeys.fieldFooterHeadlineAr),
            controllerEn: _footerHeadlineEn,
            controllerAr: _footerHeadlineAr,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldFooterAvailabilityEn),
            labelAr: t(LangKeys.fieldFooterAvailabilityAr),
            controllerEn: _footerAvailabilityEn,
            controllerAr: _footerAvailabilityAr,
            maxLines: 3,
          ),
        ],
      ),
      _Group(
        title: t(LangKeys.groupFeaturedWorks),
        children: <Widget>[
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldHomeWorksHeadlineEn),
            labelAr: t(LangKeys.fieldHomeWorksHeadlineAr),
            controllerEn: _worksHeadlineEn,
            controllerAr: _worksHeadlineAr,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldHomeWorksSubtitleEn),
            labelAr: t(LangKeys.fieldHomeWorksSubtitleAr),
            controllerEn: _worksSubtitleEn,
            controllerAr: _worksSubtitleAr,
            maxLines: 2,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldHomeWorksMoreLabelEn),
            labelAr: t(LangKeys.fieldHomeWorksMoreLabelAr),
            controllerEn: _worksMoreLabelEn,
            controllerAr: _worksMoreLabelAr,
          ),
          BilingualFieldPair(
            labelEn: t(LangKeys.fieldHomeWorksViewAllEn),
            labelAr: t(LangKeys.fieldHomeWorksViewAllAr),
            controllerEn: _worksViewAllEn,
            controllerAr: _worksViewAllAr,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormScreen(
      title: context.translate(LangKeys.formEditSiteContent),
      fieldsBuilder: _fields,
      onSave: _submit,
    );
  }
}

/// One collapsible group of fields.
///
/// `maintainState` is on so a collapsed group's fields stay in the enclosing
/// [Form]. Without it, Save would validate only whatever happens to be open,
/// and a required field two groups down would pass unseen.
class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ExpansionTile(
      title: Text(title, style: MyFonts.semi16.copyWith(color: colors.onNavy)),
      initiallyExpanded: initiallyExpanded,
      maintainState: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.only(bottom: 16.h),
      iconColor: colors.accent,
      collapsedIconColor: colors.onNavyMuted,
      expansionAnimationStyle: AnimationStyle.noAnimation,
      children: children,
    );
  }
}
