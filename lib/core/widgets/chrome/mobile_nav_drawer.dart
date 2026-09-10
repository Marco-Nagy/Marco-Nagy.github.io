import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/extension/navigation_extensions.dart';
import '../../utils/extension/site_content_extensions.dart';
import 'monogram_logo.dart';
import '../../routes/route_names.dart';
import '../../../features/portfolio_content/domain/entities/section_definition.dart';
import 'resume_button.dart';

/// The nav collapsed for mobile and tablet. Mirrors automatically in Arabic
/// because [Drawer] follows the ambient [Directionality].
class MobileNavDrawer extends StatelessWidget {
  const MobileNavDrawer({required this.currentSectionId, super.key});

  final String currentSectionId;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.pageTop,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MonogramLogo(),
              SizedBox(height: 32.h),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    for (final section in context.visibleSections)
                      _DrawerLink(
                        label: context.localized(
                          section.titleEn,
                          section.titleAr,
                        ),
                        section: section,
                        isActive: section.id == currentSectionId,
                      ),
                  ],
                ),
              ),
              const ResumeButton(),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.label,
    required this.section,
    required this.isActive,
  });

  final String label;
  final SectionDefinition section;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: MyFonts.bold22.copyWith(
          color: isActive ? colors.accent : colors.onNavy,
        ),
      ),
      trailing: isActive
          ? Icon(Icons.circle, size: 8.r, color: colors.accent)
          : null,
      onTap: () {
        // Close the drawer first so it is not left open behind the new screen.
        context.pop();
        if (!isActive) {
          context.replaceNamed<void>(RouteNames.forSection(section));
        }
      },
    );
  }
}
