import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../../core/utils/responsive/app_breakpoints.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../core/widgets/admin/admin_item_actions.dart';
import '../../../../core/widgets/common/app_media.dart';
import '../../../../core/widgets/common/pill_button.dart';
import '../../../../core/widgets/common/safe_asset_image.dart';
import '../../../portfolio_content/presentation/view_data/list_row_data.dart';

/// A numbered project row.
///
/// On desktop the accent block and rotated preview slide in on hover. On touch
/// there is no hover, so a tap plays that same reveal, waits for it to finish,
/// and only then navigates — mobile visitors see the motion instead of an
/// instant screen change.
class ProjectListRow extends StatefulWidget {
  const ProjectListRow({
    required this.data,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ListRowData data;

  /// Awaited, so the row stays revealed until the detail view is dismissed.
  final Future<void> Function() onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Drives both the reveal animation and the pre-navigation wait, so the two
  /// can never drift apart.
  static const Duration kRevealDuration = Motion.quick;

  @override
  State<ProjectListRow> createState() => _ProjectListRowState();
}

class _ProjectListRowState extends State<ProjectListRow> {
  bool _revealed = false;
  bool _navigating = false;

  Future<void> _handleTap() async {
    // Guards against a double tap pushing the same route twice.
    if (_navigating) return;
    _navigating = true;

    // Already revealed by hover: the visitor has seen the motion, so don't
    // charge them the delay a second time.
    try {
      if (!_revealed) {
        setState(() => _revealed = true);
        await Future<void>.delayed(ProjectListRow.kRevealDuration);
        if (!mounted) return;
      }
      await widget.onOpen();
    } finally {
      // Without finally, a throw from onOpen() strands _navigating true and
      // the row can never be tapped again.
      if (mounted) {
        setState(() {
          _revealed = false;
          _navigating = false;
        });
      } else {
        _navigating = false;
      }
    }
  }

  void _setHover(bool hovered) {
    if (_navigating) return;
    setState(() => _revealed = hovered);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = HexColor.parse(widget.data.accentHex, colors.accent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: ProjectListRow.kRevealDuration,
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            vertical: context.isMobile ? 24.h : 30.h,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.divider.withValues(alpha: 0.7)),
            ),
          ),
          child: Stack(
            // The preview is taller than the row and leans out of it, exactly
            // as the reference does — clipping it to the row bounds would saw
            // the corners off the rotated card.
            clipBehavior: Clip.none,
            children: <Widget>[
              // The accent block slides in behind the row content.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: ProjectListRow.kRevealDuration,
                    opacity: _revealed ? 1 : 0,
                    child: _RevealBlock(
                      accent: accent,
                      data: widget.data,
                      revealed: _revealed,
                    ),
                  ),
                ),
              ),
              context.isMobile
                  ? _NarrowRowContent(
                      data: widget.data,
                      accent: accent,
                      revealed: _revealed,
                      onOpen: _handleTap,
                      onEdit: widget.onEdit,
                      onDelete: widget.onDelete,
                    )
                  : _WideRowContent(
                      data: widget.data,
                      accent: accent,
                      revealed: _revealed,
                      onOpen: _handleTap,
                      onEdit: widget.onEdit,
                      onDelete: widget.onDelete,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colored wash plus the rotated, overlapping screenshot preview.
class _RevealBlock extends StatelessWidget {
  const _RevealBlock({
    required this.accent,
    required this.data,
    required this.revealed,
  });

  final Color accent;
  final ListRowData data;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: <Color>[
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: EdgeInsetsDirectional.only(end: 32.w),
          child: AnimatedSlide(
            duration: ProjectListRow.kRevealDuration,
            curve: Curves.easeOut,
            offset: Offset(revealed ? 0 : 0.15 * (context.isRtl ? -1 : 1), 0),
            child: Transform.rotate(
              angle: -8 * math.pi / 180,
              child: Container(
                // Sized against the 1440 design width the desktop breakpoint
                // uses: the reference gives this preview roughly a quarter of
                // the viewport, where 120.w was leaving it at eight percent —
                // a thumbnail rather than the artwork the row is selling.
                width: context.isMobile ? 190.w : 340.w,
                height: context.isMobile ? 130.h : 220.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: accent.withValues(alpha: 0.6)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: context.colors.pageTop.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9.r),
                  child: AppMedia(
                    media: data.cover,
                    // The reveal is rotated, so no platform view survives here;
                    // a YouTube cover degrades to its poster.
                    playing: revealed,
                    allowPlatformView: false,
                    fallback: AssetPlaceholder(label: data.title),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WideRowContent extends StatelessWidget {
  const _WideRowContent({
    required this.data,
    required this.accent,
    required this.revealed,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ListRowData data;
  final Color accent;
  final bool revealed;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Growing this is what moves the number and title — see
        // _RowLeaderLine. Nothing downstream needs its own transform.
        _RowLeaderLine(revealed: revealed),
        SizedBox(
          width: 64.w,
          child: Text(
            data.index,
            style: MyFonts.index20.copyWith(color: accent),
          ),
        ),
        Expanded(
          child: _TitleAndCategory(
            data: data,
            accent: accent,
            revealed: revealed,
          ),
        ),
        AdminItemActions(onEdit: onEdit, onDelete: onDelete),
        SizedBox(width: 12.w),
        PillButton(
          label: context.translate(LangKeys.projectsViewProject),
          variant: PillButtonVariant.outlined,
          dense: true,
          onPressed: onOpen,
        ),
      ],
    );
  }
}

class _NarrowRowContent extends StatelessWidget {
  const _NarrowRowContent({
    required this.data,
    required this.accent,
    required this.revealed,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ListRowData data;
  final Color accent;
  final bool revealed;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(data.index, style: MyFonts.index20.copyWith(color: accent)),
            const Spacer(),
            AdminItemActions(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
        SizedBox(height: 10.h),
        _TitleAndCategory(data: data, accent: accent, revealed: revealed),
        SizedBox(height: 18.h),
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: PillButton(
              label: context.translate(LangKeys.projectsViewProject),
              variant: PillButtonVariant.outlined,
              dense: true,
              onPressed: onOpen,
            ),
          ),
        ),
      ],
    );
  }
}

/// The rule running from the row's leading edge to the index number.
///
/// On the reference site, hovering a row does not slide the number and title
/// with a transform of their own — it widens this rule, and the text is
/// simply carried along by the extra space ahead of it. One animated width
/// drives both the line and the shift, so they can never drift apart or need
/// separate durations.
class _RowLeaderLine extends StatelessWidget {
  const _RowLeaderLine({required this.revealed});

  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ProjectListRow.kRevealDuration,
      curve: Curves.easeOut,
      width: revealed
          ? Motion.rowLeaderHoverWidth.w
          : Motion.rowLeaderIdleWidth.w,
      height: 1,
      margin: EdgeInsetsDirectional.only(end: 18.w),
      color: context.colors.divider,
    );
  }
}

class _TitleAndCategory extends StatelessWidget {
  const _TitleAndCategory({
    required this.data,
    required this.accent,
    required this.revealed,
  });

  final ListRowData data;
  final Color accent;

  /// Idle rows read as dimmed, and the hovered (or tap-revealed) row alone
  /// reads at full brightness — the reference dims every row but the one
  /// being pointed at, rather than keeping titles uniformly bright.
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedDefaultTextStyle(
          duration: ProjectListRow.kRevealDuration,
          curve: Curves.easeOut,
          style: (context.isMobile ? MyFonts.bold28 : MyFonts.display36)
              .copyWith(color: revealed ? colors.onNavy : colors.onNavyMuted),
          child: Text(data.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        if (data.category.trim().isNotEmpty) ...<Widget>[
          SizedBox(height: 6.h),
          Text(
            data.category.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MyFonts.caps10.copyWith(color: accent),
          ),
        ],
      ],
    );
  }
}
