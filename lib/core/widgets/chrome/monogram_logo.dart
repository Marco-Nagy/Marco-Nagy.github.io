import 'package:flutter/material.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/extension/site_content_extensions.dart';
import '../../routes/route_names.dart';
import '../../utils/extension/navigation_extensions.dart';

/// The "MN" mark, top-leading on every page. Tapping it returns to the top.
class MonogramLogo extends StatelessWidget {
  const MonogramLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.replaceNamed<void>(RouteNames.home),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              context.site.monogram,
              style: MyFonts.bold28.copyWith(
                color: context.colors.onNavy,
                letterSpacing: 1,
              ),
            ),
            Text(
              '.',
              style: MyFonts.bold28.copyWith(color: context.colors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
