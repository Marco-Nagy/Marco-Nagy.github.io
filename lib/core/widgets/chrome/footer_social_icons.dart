import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../localization/lang_keys.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/extension/site_content_extensions.dart';
import '../../utils/url_opener.dart';
import '../motion/motion_durations.dart';

/// GitHub + LinkedIn only. Both open the profile in a new tab.
class FooterSocialIcons extends StatelessWidget {
  const FooterSocialIcons({this.spacing, super.key});

  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final links = context.siteLinks;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SocialIconButton(
          icon: Icons.code_rounded,
          label: context.translate(LangKeys.footerGithub),
          onPressed: () => UrlOpener.open(links.gitHubUrl),
        ),
        SizedBox(width: spacing ?? 12.w),
        SocialIconButton(
          icon: Icons.business_center_outlined,
          label: context.translate(LangKeys.footerLinkedin),
          onPressed: () => UrlOpener.open(links.linkedInUrl),
        ),
      ],
    );
  }
}

class SocialIconButton extends StatefulWidget {
  const SocialIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final Future<bool> Function() onPressed;

  @override
  State<SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<SocialIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          // The icon is 20.r inside a ~44px circle; without this only the
          // glyph itself is tappable.
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onPressed(),
          child: AnimatedContainer(
            duration: Motion.quick,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hovered
                  ? colors.accent.withValues(alpha: 0.14)
                  : colors.transparent,
              border: Border.all(
                color: _hovered ? colors.accent : colors.divider,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 20.r,
              color: _hovered ? colors.accent : colors.onNavyMuted,
            ),
          ),
        ),
      ),
    );
  }
}
