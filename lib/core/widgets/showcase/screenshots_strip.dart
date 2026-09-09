import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/portfolio_content/domain/entities/media_shot.dart';
import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../../features/portfolio_content/domain/entities/showcase_panel.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/hex_color.dart';
import 'device_frame.dart';
import 'panel_caption.dart';
import 'shot_background_view.dart';

/// One continuous horizontal strip of device-framed shots — one panel per
/// uploaded screenshot, laid edge to edge as a single linear group rather
/// than as separated cards.
///
/// Backgrounds and device frames are painted in two passes over one shared
/// [Stack] instead of each panel drawing (and clipping) its own card: a
/// rotated or oversized frame is meant to spill past its own panel's edge,
/// so the strip only clips at its own outer edges, and an overflowing frame
/// paints on top of the adjoining panel exactly where it lands.
///
/// Shared by the project detail page's [ScreenshotsSection] (the full-size
/// strip a visitor scrolls) and the admin screenshot editor's live preview
/// (a narrow version showing a screenshot beside the ones already added) —
/// both want the same "panels laid side by side, frames free to overflow"
/// behaviour, just at different sizes.
class ScreenshotsStrip extends StatelessWidget {
  const ScreenshotsStrip({
    required this.panels,
    required this.background,
    required this.height,
    this.borderRadius,
    this.maxWidth,
    this.playing = true,
    this.activePanelId,
    super.key,
  });

  final List<ShowcasePanel> panels;
  final ShotBackground background;
  final double height;

  /// False stops every panel's device frame from animating — a looping GIF
  /// screenshot otherwise keeps decoding frames for as long as this widget
  /// stays mounted, including while it sits, out of sight, under whatever
  /// route got pushed on top of the page it's on.
  final bool playing;

  /// When given, only the panel with this id actually plays — every other
  /// panel is frozen regardless of [playing]. The screenshot editor's own
  /// preview passes its own panel's id here: judging one shot's rotation or
  /// scale needs that one shot moving, not every sibling GIF looping at the
  /// same time on top of the sliders themselves being dragged, which on
  /// Flutter Web is expensive enough per GIF that it compounds with each one
  /// left running.
  final String? activePanelId;

  /// Defaults to a full-size strip's rounding; the admin preview passes a
  /// smaller value to match its own card chrome.
  final double? borderRadius;

  /// When given, every panel shares this width instead of a fixed
  /// [aspectRatio]-derived one: each panel gets `maxWidth / panels.length`,
  /// shrinking as more screenshots are added so the whole group keeps
  /// fitting without a scrollbar — capped at the natural size, so a single
  /// screenshot is never stretched wider than its own frame calls for. This
  /// is the admin preview's shape: it has a fixed box to fit into and wants
  /// every screenshot visible at once, not a page strip's fixed-size cards
  /// browsed by scrolling sideways.
  final double? maxWidth;

  static const double aspectRatio = 9 / 16;

  @override
  Widget build(BuildContext context) {
    if (panels.isEmpty) return const SizedBox.shrink();

    final naturalWidth = height * aspectRatio;
    final available = maxWidth;
    final panelWidth = available == null
        ? naturalWidth
        : math.min(naturalWidth, available / panels.length);
    final totalWidth = panelWidth * panels.length;

    final stack = SizedBox(
      width: totalWidth,
      height: height,
      child: Stack(
        // The strip itself is the only thing that clips; a panel's frame
        // must be free to paint into its neighbour's slot.
        clipBehavior: Clip.none,
        children: <Widget>[
          for (var i = 0; i < panels.length; i++)
            Positioned(
              left: i * panelWidth,
              width: panelWidth,
              height: height,
              child: ShotBackgroundView(
                background: panels[i].backgroundOverride ?? background,
              ),
            ),
          // Painted after every background, so a frame that overflows its
          // own panel's edge lands on top of the neighbour's background
          // rather than being clipped away.
          for (var i = 0; i < panels.length; i++)
            _ScreenshotFrame(
              panel: panels[i],
              left: i * panelWidth,
              panelWidth: panelWidth,
              panelHeight: height,
              caption: context.localized(
                panels[i].captionEn,
                panels[i].captionAr,
              ),
              subtitle: context.localized(
                panels[i].subtitleEn,
                panels[i].subtitleAr,
              ),
              playing:
                  playing &&
                  (activePanelId == null || panels[i].id == activePanelId),
            ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
      child: SizedBox(
        height: height,
        // A fixed maxWidth already shrank every panel to fit — nothing left
        // to scroll. Without one (the page strip), panels keep their natural
        // size and the strip scrolls sideways instead.
        child: available == null
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: stack,
              )
            : stack,
      ),
    );
  }
}

/// One panel's device frame and caption, positioned at its slot in the
/// strip. Never clips its own bounds — see [ScreenshotsStrip]'s doc comment
/// for why that is the point.
class _ScreenshotFrame extends StatelessWidget {
  const _ScreenshotFrame({
    required this.panel,
    required this.left,
    required this.panelWidth,
    required this.panelHeight,
    required this.caption,
    required this.subtitle,
    required this.playing,
  });

  final ShowcasePanel panel;
  final double left;
  final double panelWidth;
  final double panelHeight;
  final String caption;
  final String subtitle;
  final bool playing;

  /// A portrait panel is dominated by one phone.
  static const double _deviceWidthFactor = 0.74;

  MediaShot get _shot =>
      panel.shots.isEmpty ? const MediaShot() : panel.shots.first;

  @override
  Widget build(BuildContext context) {
    final shot = _shot;

    return Positioned(
      left: left,
      width: panelWidth,
      height: panelHeight,
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: <Widget>[
            Center(
              child: Transform.translate(
                offset: Offset(
                  shot.offsetX * panelWidth,
                  shot.offsetY * panelHeight,
                ),
                child: Transform.rotate(
                  angle: shot.rotationDegrees * math.pi / 180,
                  child: DeviceFrame(
                    image: shot.image,
                    frame: shot.frame,
                    width: panelWidth * _deviceWidthFactor * shot.scale,
                    label: caption,
                    playing: playing,
                  ),
                ),
              ),
            ),
            PanelCaption(
              caption: caption,
              subtitle: subtitle,
              placement: panel.captionPlacement,
              color: HexColor.parse(
                panel.captionColorHex,
                context.colors.onNavy,
              ),
              panelWidth: panelWidth,
            ),
          ],
        ),
      ),
    );
  }
}
