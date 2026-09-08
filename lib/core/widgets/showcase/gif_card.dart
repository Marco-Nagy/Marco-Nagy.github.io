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

/// One GIF card: background, the loop filling the card edge to edge, caption
/// on top.
///
/// Complete on its own — a GIF animates the moment it is mounted and has no
/// play/pause state to manage, unlike [VideoCard]; it does not carry
/// [VideoCard]'s tap handling for a behaviour it never needs.
class GifCard extends StatelessWidget {
  const GifCard({
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

  static const double aspectRatio = 9 / 16;

  MediaRef get _media {
    final shots = panel.shots;
    return shots.isEmpty ? const MediaRef() : shots.first.image;
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = width;

    return RepaintBoundary(
      child: SizedBox(
        width: panelWidth,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ShotBackgroundView(background: background),
              AppMedia(
                media: _media,
                fit: BoxFit.cover,
                allowPlatformView: false,
                fallback: const AssetPlaceholder(icon: Icons.gif_box_outlined),
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
      ),
    );
  }
}
