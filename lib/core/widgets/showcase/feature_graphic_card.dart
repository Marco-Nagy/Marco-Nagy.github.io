import 'package:flutter/material.dart';

import '../../../features/portfolio_content/domain/entities/media_ref.dart';
import '../../../features/portfolio_content/domain/entities/shot_background.dart';
import '../../../features/portfolio_content/domain/entities/showcase_panel.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/hex_color.dart';
import '../common/app_media.dart';
import '../common/safe_asset_image.dart';
import 'panel_caption.dart';
import 'shot_background_view.dart';
import 'tappable_video.dart';

/// One feature-graphic banner: background, the picture filling it edge to
/// edge, caption on top.
///
/// Complete on its own — no device frame, no rotate/scale/offset, no shared
/// "positioned shot" logic with [ScreenshotCard]. A feature graphic is one
/// flat image at the Play Store's own 1024×500 proportions; wiring it through
/// the same widget that frames a phone screenshot is what previously let a
/// feature graphic pick up a stray device bezel.
class FeatureGraphicCard extends StatefulWidget {
  const FeatureGraphicCard({
    required this.panel,
    required this.background,
    required this.caption,
    required this.subtitle,
    required this.width,
    super.key,
  });

  final ShowcasePanel panel;

  /// Already resolved: the panel's own override, else the project default.
  final ShotBackground background;

  /// Already resolved into the active language.
  final String caption;
  final String subtitle;

  final double width;

  static const double aspectRatio = 1024 / 500;

  @override
  State<FeatureGraphicCard> createState() => _FeatureGraphicCardState();
}

class _FeatureGraphicCardState extends State<FeatureGraphicCard> {
  /// A video feature graphic waits for a tap, same as [VideoCard] — a banner
  /// is not exempt from the rule that nothing plays before it is asked to.
  bool _playing = false;

  MediaRef get _media {
    final shots = widget.panel.shots;
    return shots.isEmpty ? const MediaRef() : shots.first.image;
  }

  bool get _isVideoFile => _media.kind == MediaKind.videoFile;

  @override
  Widget build(BuildContext context) {
    final panelWidth = widget.width;

    // Not inside any rotated/clipped ancestor here (see FeatureGraphicSection),
    // so the platform view a YouTube embed needs is safe to allow.
    final media = AppMedia(
      media: _media,
      fit: BoxFit.cover,
      allowPlatformView: true,
      playing: _isVideoFile ? _playing : true,
      fallback: const AssetPlaceholder(icon: Icons.image_outlined),
    );

    return RepaintBoundary(
      child: SizedBox(
        width: panelWidth,
        child: AspectRatio(
          aspectRatio: FeatureGraphicCard.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ShotBackgroundView(background: widget.background),
              _isVideoFile
                  ? TappableVideo(
                      playing: _playing,
                      onTap: () => setState(() => _playing = !_playing),
                      child: media,
                    )
                  : media,
              PanelCaption(
                caption: widget.caption,
                subtitle: widget.subtitle,
                placement: widget.panel.captionPlacement,
                color: HexColor.parse(
                  widget.panel.captionColorHex,
                  context.colors.onNavy,
                ),
                panelWidth: panelWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
