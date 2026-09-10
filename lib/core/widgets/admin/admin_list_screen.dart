import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';

/// Chrome for an admin screen that *manages a list* rather than editing one
/// record: skill groups, sections.
///
/// Deliberately not [AdminFormScreen]. That one owns a [Form], validates on
/// the way out, and docks a Save bar — none of which applies here, because
/// these screens save each change as it is made and have nothing to validate
/// at the page level. Sharing the scaffold would mean a Save button that
/// saves nothing.
class AdminListScreen extends StatelessWidget {
  const AdminListScreen({required this.title, required this.body, super.key});

  final String title;
  final Widget body;

  /// Pushes any manage-a-list screen. Untyped result: these screens save as
  /// they go, so there is nothing to hand back on the way out.
  static Future<void> open(BuildContext context, Widget screen) {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageTop,
      appBar: AppBar(
        backgroundColor: colors.pageTop,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close_rounded, color: colors.onNavyMuted),
        ),
        title: Text(
          title,
          style: MyFonts.bold22.copyWith(color: colors.onNavy),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720.w),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
