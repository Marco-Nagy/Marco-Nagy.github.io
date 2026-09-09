import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../di/di.dart';
import '../../../features/portfolio_content/domain/use_cases/bundle_use_case.dart'
    show BundleExport, BundleUseCase;
import '../../common/data_result.dart';
import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import 'admin_gate.dart';
import 'admin_svg_icons.dart';

/// The one site-wide admin entry point, mounted once in `PortfolioScaffold`.
///
/// A speed-dial rather than a single button because the store-wide actions
/// (export now; publish, sign-in and the site-content forms as later phases
/// land) belong to no particular list, so they have nowhere else to live.
/// Per-list add/edit/delete stays inline on the list, via `AdminAddButton` and
/// `AdminItemActions` — those must dispatch into their own cubit, which a
/// page-level control sits outside of.
///
/// Wrapped in [AdminGate], so release builds do not merely hide it: the whole
/// subtree, including the export path, is tree-shaken away.
class AdminFab extends StatefulWidget {
  const AdminFab({super.key});

  @override
  State<AdminFab> createState() => _AdminFabState();
}

class _AdminFabState extends State<AdminFab> {
  bool _open = false;
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await getIt<BundleUseCase>().exportJson();
    if (!mounted) return;

    // Read every context-dependent value before the await inside
    // Clipboard.setData, and hold the messenger rather than the context: the
    // widget can be disposed while the platform channel is in flight.
    final messenger = ScaffoldMessenger.maybeOf(context);
    final copied = context.translate(LangKeys.adminExportCopied);
    final failed = context.translate(LangKeys.adminExportFailed);
    final oversize = context.translate(LangKeys.adminExportOversize);
    final embedded = context.translate(LangKeys.adminExportEmbedded);
    final danger = context.colors.danger;

    switch (result) {
      case Success<BundleExport>(data: final export):
        await Clipboard.setData(ClipboardData(text: export.json));

        // Copying still happens — the text is useful for inspecting what went
        // wrong — but the result says plainly whether it can be published,
        // rather than letting Firestore reject it later with no context.
        final problems = <String>[
          if (!export.fitsFirestore) oversize,
          if (export.hasEmbeddedImages)
            '$embedded (${export.embeddedImageCount})',
        ];
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: problems.isEmpty ? null : danger,
            duration: Duration(seconds: problems.isEmpty ? 4 : 8),
            content: Text(
              <String>[
                '$copied — ${export.sizeLabel}',
                ...problems,
              ].join('\n'),
            ),
          ),
        );
      case Fail<BundleExport>(message: final message):
        messenger?.showSnackBar(SnackBar(content: Text('$failed: $message')));
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (_open)
            _AdminFabAction(
              label: context.translate(LangKeys.adminExport),
              busy: _busy,
              onPressed: _export,
            ),
          SizedBox(height: 12.h),
          FloatingActionButton.extended(
            heroTag: 'admin-fab',
            onPressed: () => setState(() => _open = !_open),
            backgroundColor: context.colors.accent,
            foregroundColor: context.colors.pageTop,
            icon: _open
                ? Icon(Icons.close, size: 18.r)
                : SvgPicture.string(
                    AdminSvgIcons.add,
                    width: 18.r,
                    height: 18.r,
                    colorFilter: ColorFilter.mode(
                      context.colors.pageTop,
                      BlendMode.srcIn,
                    ),
                  ),
            label: Text(
              context
                  .translate(
                    _open ? LangKeys.adminMenuClose : LangKeys.adminMenu,
                  )
                  .toUpperCase(),
              style: MyFonts.caps10.copyWith(color: context.colors.pageTop),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of the expanded dial.
class _AdminFabAction extends StatelessWidget {
  const _AdminFabAction({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 8.h),
      child: FloatingActionButton.extended(
        heroTag: 'admin-fab-$label',
        onPressed: busy ? null : onPressed,
        backgroundColor: context.colors.pageTop,
        foregroundColor: context.colors.accent,
        icon: busy
            ? SizedBox(
                width: 16.r,
                height: 16.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.accent,
                ),
              )
            : Icon(Icons.download_rounded, size: 18.r),
        label: Text(
          label.toUpperCase(),
          style: MyFonts.caps10.copyWith(color: context.colors.accent),
        ),
      ),
    );
  }
}
