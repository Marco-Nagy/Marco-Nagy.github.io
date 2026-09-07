import 'package:flutter/material.dart';

import '../../../../core/widgets/chrome/portfolio_scaffold.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../widgets/featured_works_section.dart';
import '../widgets/hero_section.dart';

/// The landing screen: the hero, then a slice of the work, with the shared nav
/// and footer around them.
///
/// The hero's CTA and scroll cue travel to the works block on this page rather
/// than routing away — the work is right here, and `/projects` is what the link
/// at the end of the block is for.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _worksKey = GlobalKey();

  void _scrollToWorks() {
    final target = _worksKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: Motion.scrollToSection,
      curve: Motion.scrollCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PortfolioScaffold(
      activeSectionId: BuiltInSectionIds.home,
      children: <Widget>[
        HeroSection(onSeeWorks: _scrollToWorks),
        FeaturedWorksSection(key: _worksKey),
      ],
    );
  }
}
