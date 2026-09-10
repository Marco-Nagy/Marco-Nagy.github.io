import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/extension/context_extensions.dart';
import '../../utils/extension/site_content_extensions.dart';
import '../../utils/responsive/app_breakpoints.dart';
import '../admin/admin_reset_button.dart';
import 'language_toggle.dart';
import 'monogram_logo.dart';
import 'nav_link.dart';
import 'resume_button.dart';

/// Site chrome pinned above the scrolling page: monogram leading, links inline
/// on wide screens (collapsed into a drawer otherwise), language toggle and the
/// outlined RESUME pill trailing.
class TopNavBar extends StatelessWidget {
  const TopNavBar({required this.activeSectionId, this.onOpenMenu, super.key});

  /// Section currently in view, highlighted in the link row.
  final String activeSectionId;
  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final showInlineLinks = context.isDesktop;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 20.w : 48.w,
        vertical: 18.h,
      ),
      decoration: BoxDecoration(
        // Sits above the scrolling content, so it needs its own ground rather
        // than letting sections show through as they pass under it.
        color: context.colors.pageTop.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: context.colors.divider.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          const MonogramLogo(),
          const Spacer(),
          if (showInlineLinks)
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final section in context.visibleSections)
                      NavLink(
                        label: context.localized(
                          section.titleEn,
                          section.titleAr,
                        ),
                        section: section,
                        isActive: section.id == activeSectionId,
                      ),
                  ],
                ),
              ),
            ),
          SizedBox(width: 16.w),
          // Debug-only: restore seeded content after experimenting.
          const AdminResetButton(),
          const LanguageToggle(),
          SizedBox(width: 12.w),
          if (showInlineLinks)
            const ResumeButton(dense: true)
          else
            IconButton(
              onPressed: onOpenMenu,
              icon: Icon(
                Icons.menu_rounded,
                color: context.colors.onNavy,
                size: 26.r,
              ),
            ),
        ],
      ),
    );
  }
}
