import 'package:flutter/material.dart';

import '../../utils/extension/context_extensions.dart';
import 'motion_durations.dart';
import 'reveal_trigger.dart';

/// Text that arrives the way the reference site's does: a solid panel sweeps
/// across each line to cover it, then retracts off the opposite edge, wiping
/// the glyphs into view.
///
/// The text itself never moves and never fades — it is simply uncovered. That
/// is the whole difference from a fade-and-rise reveal, and it is why the
/// block has to be measured per *line* rather than per widget: a panel the
/// width of the paragraph box would overhang every short line and read as a
/// rectangle switching off, not as a wipe.
///
/// All lines share one 0..1 timeline and land together — the reference has no
/// per-line stagger, and adding one makes a paragraph read as a list.
class BlockRevealText extends StatefulWidget {
  const BlockRevealText(
    this.text, {
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.blockColor,
    this.delay = Duration.zero,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;

  /// Defaults to the curtain's own colour, so a line wipe reads as the same
  /// material as the page wipe that preceded it.
  final Color? blockColor;

  /// Held before the wipe starts. Callers stagger *sections*, never lines.
  final Duration delay;

  @override
  State<BlockRevealText> createState() => _BlockRevealTextState();
}

class _BlockRevealTextState extends State<BlockRevealText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.blockCover + Motion.blockReveal,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start({required bool instant}) {
    if (instant) {
      _controller.value = 1;
      return;
    }
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);

    return RevealTrigger(
      delay: widget.delay,
      onReveal: _start,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _BlockRevealTextBox(
          text: TextSpan(text: widget.text, style: style),
          textDirection: Directionality.of(context),
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          blockColor: widget.blockColor ?? context.colors.onNavy,
          progress: _controller.value,
        ),
      ),
    );
  }
}

class _BlockRevealTextBox extends LeafRenderObjectWidget {
  const _BlockRevealTextBox({
    required this.text,
    required this.textDirection,
    required this.textAlign,
    required this.maxLines,
    required this.blockColor,
    required this.progress,
  });

  final InlineSpan text;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final int? maxLines;
  final Color blockColor;
  final double progress;

  @override
  _RenderBlockRevealText createRenderObject(BuildContext context) {
    return _RenderBlockRevealText(
        text: text,
        textDirection: textDirection,
        textAlign: textAlign,
        maxLines: maxLines,
        textScaler: MediaQuery.textScalerOf(context),
      )
      ..blockColor = blockColor
      ..progress = progress;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBlockRevealText renderObject,
  ) {
    renderObject
      ..text = text
      ..textDirection = textDirection
      ..textAlign = textAlign
      ..maxLines = maxLines
      ..blockColor = blockColor
      ..progress = progress
      ..textScaler = MediaQuery.textScalerOf(context);
  }
}

class _RenderBlockRevealText extends RenderBox {
  _RenderBlockRevealText({
    required InlineSpan text,
    required TextDirection textDirection,
    required TextAlign textAlign,
    required int? maxLines,
    required TextScaler textScaler,
  }) : _painter = TextPainter(
         text: text,
         textDirection: textDirection,
         textAlign: textAlign,
         maxLines: maxLines,
         textScaler: textScaler,
       );

  final TextPainter _painter;

  /// Both are set by the widget immediately after construction, so the
  /// placeholders here are never painted.
  Color _blockColor = const Color.fromARGB(255, 104, 196, 253);
  double _progress = 0;

  set text(InlineSpan value) {
    if (_painter.text == value) return;
    _painter.text = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (_painter.textDirection == value) return;
    _painter.textDirection = value;
    markNeedsLayout();
  }

  set textAlign(TextAlign value) {
    if (_painter.textAlign == value) return;
    _painter.textAlign = value;
    markNeedsLayout();
  }

  set maxLines(int? value) {
    if (_painter.maxLines == value) return;
    _painter.maxLines = value;
    markNeedsLayout();
  }

  set textScaler(TextScaler value) {
    if (_painter.textScaler == value) return;
    _painter.textScaler = value;
    markNeedsLayout();
  }

  set blockColor(Color value) {
    if (_blockColor == value) return;
    _blockColor = value;
    markNeedsPaint();
  }

  /// Only the panels move, so a new frame repaints without re-laying-out the
  /// paragraph — the expensive half runs once per size change, not per frame.
  set progress(double value) {
    if (_progress == value) return;
    _progress = value;
    markNeedsPaint();
  }

  void _layoutText(double maxWidth) =>
      _painter.layout(maxWidth: maxWidth.isFinite ? maxWidth : double.infinity);

  @override
  double computeMinIntrinsicWidth(double height) {
    _layoutText(double.infinity);
    return _painter.minIntrinsicWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _layoutText(double.infinity);
    return _painter.maxIntrinsicWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    _layoutText(width);
    return _painter.height;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    _layoutText(constraints.maxWidth);
    return _painter.computeDistanceToActualBaseline(baseline);
  }

  @override
  void performLayout() {
    _layoutText(constraints.maxWidth);
    size = constraints.constrain(Size(_painter.width, _painter.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _layoutText(constraints.maxWidth);
    _painter.paint(context.canvas, offset);

    if (_progress >= 1) return;

    final paint = Paint()..color = _blockColor;
    final isRtl = _painter.textDirection == TextDirection.rtl;

    for (final line in _painter.computeLineMetrics()) {
      if (line.width <= 0) continue;

      // The panel spans [from, to] of the line's own width. Covering pins the
      // leading edge and grows; revealing pins the trailing edge and shrinks —
      // the same two-phase move the page curtain makes, one line wide.
      final double from;
      final double to;
      if (_progress < Motion.blockCoverFraction) {
        final t = Motion.curtainCurve.transform(
          _progress / Motion.blockCoverFraction,
        );
        from = 0;
        to = line.width * t;
      } else {
        final t = Motion.curtainCurve.transform(
          (_progress - Motion.blockCoverFraction) /
              (1 - Motion.blockCoverFraction),
        );
        from = line.width * t;
        to = line.width;
      }
      if (to <= from) continue;

      // `line.left` is already the laid-out leading edge for the direction, so
      // in Arabic the panel mirrors without a second code path.
      final lineStart = offset.dx + line.left;
      final Rect rect;
      if (isRtl) {
        final right = lineStart + line.width;
        rect = Rect.fromLTRB(
          right - to,
          offset.dy + line.baseline - line.ascent,
          right - from,
          offset.dy + line.baseline + line.descent,
        );
      } else {
        rect = Rect.fromLTRB(
          lineStart + from,
          offset.dy + line.baseline - line.ascent,
          lineStart + to,
          offset.dy + line.baseline + line.descent,
        );
      }
      context.canvas.drawRect(rect, paint);
    }
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }
}
