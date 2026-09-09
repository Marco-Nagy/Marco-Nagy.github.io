import 'package:flutter/material.dart';

import '../../utils/extension/context_extensions.dart';

/// Makes any child tappable — play when paused, pause when running — and
/// shows a play badge while paused.
///
/// Pure interaction chrome: it does not know it is wrapping a video, only
/// that it has a `playing` flag and a tap to flip it. [VideoCard] and
/// [FeatureGraphicCard] both use it for the one shot kind that can actually
/// play on its own; it carries no branching on media kind itself.
class TappableVideo extends StatelessWidget {
  const TappableVideo({
    required this.playing,
    required this.onTap,
    required this.child,
    super.key,
  });

  final bool playing;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            child,
            // Hidden once playing, so the badge never sits over the video
            // itself — only over the poster it is inviting a tap away from.
            if (!playing)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 26,
                      color: colors.pageTop,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
