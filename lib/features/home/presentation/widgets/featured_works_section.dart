import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/utils/responsive/app_breakpoints.dart';
import '../../../../core/widgets/common/content_container.dart';
import '../../../../core/widgets/motion/block_reveal_text.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../di/di.dart';
import '../../../projects/presentation/view_model/projects_actions.dart';
import '../../../projects/presentation/view_model/projects_view_model.dart';
import '../../../projects/presentation/widgets/projects_list_view.dart';

/// The home page's own slice of the work: a plain heading — not the wavy ring
/// badge, which belongs to the standalone section pages — over the first few
/// project rows, ending in a link out to the full list.
class FeaturedWorksSection extends StatelessWidget {
  const FeaturedWorksSection({super.key});

  /// How many rows the home page shows before handing off to `/projects`.
  static const int _shown = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider<ProjectsViewModelCubit>(
      create: (_) => getIt<ProjectsViewModelCubit>()..doAction(LoadProjects()),
      child: Padding(
        padding: EdgeInsets.only(top: 96.h, bottom: 96.h),
        child: ContentContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BlockRevealText(
                context.translate(LangKeys.homeWorksHeadline),
                style:
                    (context.isMobile ? MyFonts.display36 : MyFonts.display48)
                        .copyWith(color: colors.onNavy),
              ),
              SizedBox(height: 16.h),
              BlockRevealText(
                context.translate(LangKeys.homeWorksSubtitle),
                style: MyFonts.regular16.copyWith(color: colors.onNavyMuted),
              ),
              SizedBox(height: 56.h),
              const ProjectsListView(limit: _shown),
              SizedBox(height: 72.h),
              const _ViewAllLink(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The reference's sign-off out of the works list: a small caps label over an
/// oversized text link whose arrow slides away from it on hover.
class _ViewAllLink extends StatefulWidget {
  const _ViewAllLink();

  @override
  State<_ViewAllLink> createState() => _ViewAllLinkState();
}

class _ViewAllLinkState extends State<_ViewAllLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.pushNamed<void>(RouteNames.projects),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                context.translate(LangKeys.homeWorksMoreLabel).toUpperCase(),
                style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedDefaultTextStyle(
                    duration: Motion.quick,
                    curve: Curves.easeOut,
                    style:
                        (context.isMobile ? MyFonts.bold22 : MyFonts.display36)
                            .copyWith(
                              color: _hovered ? colors.accent : colors.onNavy,
                            ),
                    child: Text(context.translate(LangKeys.homeWorksViewAll)),
                  ),
                  AnimatedContainer(
                    duration: Motion.quick,
                    curve: Curves.easeOut,
                    width: _hovered ? 28.w : 16.w,
                  ),
                  // Points along the reading direction, so it mirrors in
                  // Arabic — the same move `PillButton` makes.
                  Transform.scale(
                    scaleX: context.isRtl ? -1.0 : 1.0,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 28.r,
                      color: _hovered ? colors.accent : colors.onNavy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
