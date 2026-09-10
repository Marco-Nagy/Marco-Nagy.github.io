import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../../core/utils/url_opener.dart';
import '../../../../core/widgets/chrome/footer_social_icons.dart';

/// Direct routes to Marco beside the form, for visitors who would rather not
/// fill anything in.
class ContactLinks extends StatelessWidget {
  const ContactLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final site = context.site;
    final links = context.siteLinks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate(LangKeys.contactOrReachMe).toUpperCase(),
          style: MyFonts.caps10.copyWith(color: colors.accent),
        ),
        SizedBox(height: 20.h),
        _ContactLine(
          icon: Icons.mail_outline_rounded,
          label: context.translate(LangKeys.contactEmail),
          value: links.email,
          onTap: () => UrlOpener.open(links.mailto()),
        ),
        _ContactLine(
          icon: Icons.phone_outlined,
          label: context.translate(LangKeys.contactPhone),
          value: links.phone,
          onTap: () => UrlOpener.open(links.tel),
        ),
        _ContactLine(
          icon: Icons.place_outlined,
          label: context.translate(LangKeys.aboutLocationLabel),
          value: context.localized(site.locationEn, site.locationAr),
        ),
        SizedBox(height: 28.h),
        const FooterSocialIcons(),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Future<bool> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18.r, color: colors.accent),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: MyFonts.semi16.copyWith(color: colors.onNavy),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap!(),
        child: content,
      ),
    );
  }
}
