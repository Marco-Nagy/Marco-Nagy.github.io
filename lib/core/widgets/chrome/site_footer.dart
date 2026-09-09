import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../localization/lang_keys.dart';
import '../../routes/route_names.dart';
import '../../utils/extension/navigation_extensions.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/responsive/app_breakpoints.dart';
import '../common/hatched_circle.dart';
import '../common/pill_button.dart';
import '../motion/block_reveal_text.dart';
import '../motion/reveal_on_scroll.dart';
import 'footer_social_icons.dart';

/// One site-wide footer, identical on every page — not a per-page CTA band.
class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isWide = context.isWide;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 24.w : 64.w,
        vertical: 64.h,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.divider.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        children: <Widget>[
          // The call to action wipes itself in line by line, so it is not
          // wrapped in a fade; only the ring beside it still needs one.
          const _FooterCallToAction(),
          if (!isWide) ...<Widget>[
            SizedBox(height: 32.h),
            RevealOnScroll(child: HatchedCircle(diameter: 140.w)),
          ],
          SizedBox(height: 48.h),
          Divider(color: colors.divider.withValues(alpha: 0.6)),
          SizedBox(height: 24.h),
          const _FooterCredits(),
        ],
      ),
    );
  }
}

class _FooterCallToAction extends StatelessWidget {
  const _FooterCallToAction();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final headline = BlockRevealText(
      context.translate(LangKeys.footerHeadline),
      textAlign: TextAlign.center,
      style: (context.isMobile ? MyFonts.display36 : MyFonts.display48)
          .copyWith(color: colors.onNavy),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (context.isWide)
          // The ring hangs off the headline's tail and, being the first child,
          // paints behind it — the reference overlaps the two rather than
          // setting them side by side, and the words stay readable through it.
          Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.centerEnd,
            children: <Widget>[
              PositionedDirectional(
                end: -56.w,
                child: RevealOnScroll(child: HatchedCircle(diameter: 120.w)),
              ),
              headline,
            ],
          )
        else
          headline,
        SizedBox(height: 16.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520.w),
          child: BlockRevealText(
            context.translate(LangKeys.footerAvailability),
            textAlign: TextAlign.center,
            style: MyFonts.regular16.copyWith(color: colors.onNavyMuted),
          ),
        ),
        SizedBox(height: 28.h),
        PillButton(
          label: context.translate(LangKeys.footerCta),
          onPressed: () => context.replaceNamed<void>(RouteNames.contact),
        ),
      ],
    );
  }
}

class _FooterCredits extends StatelessWidget {
  const _FooterCredits();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final year = DateTime.now().year;
    final style = MyFonts.regular12.copyWith(color: colors.onNavyFaint);

    // Stacked and centred at every width — the reference signs off down the
    // middle rather than splitting the credits across the page.
    return Column(
      children: <Widget>[
        const FooterSocialIcons(),
        SizedBox(height: 20.h),
        Text(
          '© $year ${context.translate(LangKeys.footerBuiltBy)}',
          textAlign: TextAlign.center,
          style: style,
        ),
        SizedBox(height: 6.h),
        Text(
          context.translate(LangKeys.footerBuiltWith),
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}
