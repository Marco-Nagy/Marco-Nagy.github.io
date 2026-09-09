import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/url_opener.dart';
import '../../../../core/widgets/motion/motion_durations.dart';

/// The hero's social row: underlined word links separated by slashes, the way
/// the reference anchors its landing page, rather than the icon buttons the
/// footer uses.
class HeroSocialLinks extends StatelessWidget {
  const HeroSocialLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SocialTextLink(
          label: context.translate(LangKeys.footerGithub),
          onPressed: UrlOpener.openGitHub,
        ),
        const _Separator(),
        _SocialTextLink(
          label: context.translate(LangKeys.footerLinkedin),
          onPressed: UrlOpener.openLinkedIn,
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Text(
        '/',
        style: MyFonts.regular14.copyWith(color: context.colors.accent),
      ),
    );
  }
}

class _SocialTextLink extends StatefulWidget {
  const _SocialTextLink({required this.label, required this.onPressed});

  final String label;
  final Future<bool> Function() onPressed;

  @override
  State<_SocialTextLink> createState() => _SocialTextLinkState();
}

class _SocialTextLinkState extends State<_SocialTextLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onPressed(),
        child: AnimatedDefaultTextStyle(
          duration: Motion.quick,
          curve: Curves.easeOut,
          style: MyFonts.regular14.copyWith(
            color: _hovered ? colors.onNavy : colors.onNavyMuted,
            decoration: TextDecoration.underline,
            decorationColor: _hovered ? colors.accent : colors.divider,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
