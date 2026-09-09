import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../features/portfolio_content/domain/entities/project_link.dart';
import '../../localization/lang_keys.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/url_opener.dart';
import '../../styles/fonts/my_fonts.dart';

/// The outbound links on a project's detail page — repo, store listings, live
/// demo, a sideloaded APK.
///
/// Always sorted by [ProjectLinkType]'s declaration order rather than however
/// they were entered, so the row reads web demo → Play Store → App Store →
/// GitHub → APK — descending order of proof, per the project-details content
/// rules. Empty entries and unknown/missing types are dropped rather than
/// rendered as a dead button.
class ProjectLinksRow extends StatelessWidget {
  const ProjectLinksRow({required this.links, super.key});

  final List<ProjectLink> links;

  static const List<ProjectLinkType> _proofOrder = <ProjectLinkType>[
    ProjectLinkType.web,
    ProjectLinkType.playStore,
    ProjectLinkType.appStore,
    ProjectLinkType.gitHub,
    ProjectLinkType.apk,
  ];

  @override
  Widget build(BuildContext context) {
    final byType = <ProjectLinkType, ProjectLink>{
      for (final link in links)
        if (!link.isEmpty) link.type: link,
    };
    if (byType.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: <Widget>[
        for (final type in _proofOrder)
          if (byType[type] case final link?) _ProjectLinkButton(link: link),
      ],
    );
  }
}

class _ProjectLinkButton extends StatefulWidget {
  const _ProjectLinkButton({required this.link});

  final ProjectLink link;

  @override
  State<_ProjectLinkButton> createState() => _ProjectLinkButtonState();
}

class _ProjectLinkButtonState extends State<_ProjectLinkButton> {
  bool _hovered = false;

  String _label(BuildContext context) =>
      context.translate(switch (widget.link.type) {
        ProjectLinkType.gitHub => LangKeys.projectLinkGithub,
        ProjectLinkType.playStore => LangKeys.projectLinkPlayStore,
        ProjectLinkType.appStore => LangKeys.projectLinkAppStore,
        ProjectLinkType.web => LangKeys.projectLinkWeb,
        ProjectLinkType.apk => LangKeys.projectLinkApk,
      });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hovered = _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => UrlOpener.open(widget.link.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: hovered ? colors.accent : colors.transparent,
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(color: hovered ? colors.accent : colors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _LinkIcon(
                type: widget.link.type,
                color: hovered ? colors.pageTop : colors.onNavy,
              ),
              SizedBox(width: 10.w),
              Text(
                _label(context),
                style: MyFonts.semi16.copyWith(
                  color: hovered ? colors.pageTop : colors.onNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One icon per link type. GitHub uses the site's own bundled brand mark
/// (tinted to match the button's current text colour, like every other icon
/// here) rather than a generic globe; the store types and the web demo use
/// Material glyphs close enough to their real brand shapes that adding two
/// more SVGs for them is not worth the asset weight.
class _LinkIcon extends StatelessWidget {
  const _LinkIcon({required this.type, required this.color});

  final ProjectLinkType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = 18.r;

    if (type == ProjectLinkType.gitHub) {
      return SvgPicture.asset(
        'assets/tech/gitHub.svg',
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Icon(
      switch (type) {
        ProjectLinkType.playStore => Icons.shop_outlined,
        ProjectLinkType.appStore => Icons.apple,
        ProjectLinkType.web => Icons.language_rounded,
        ProjectLinkType.apk => Icons.android_rounded,
        ProjectLinkType.gitHub => Icons.code_rounded, // unreachable
      },
      size: size,
      color: color,
    );
  }
}
