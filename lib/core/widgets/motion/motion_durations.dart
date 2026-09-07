import 'package:flutter/widgets.dart';

/// One place for every motion timing, so the site animates as one system
/// instead of each widget inventing its own feel.
class Motion {
  const Motion._();

  /// Entrance of a single element.
  static const Duration enter = Duration(milliseconds: 620);

  /// Hover / small state changes.
  static const Duration quick = Duration(milliseconds: 200);

  /// Gap between staggered siblings.
  static const Duration stagger = Duration(milliseconds: 90);

  /// Decelerating curve used for everything that enters.
  static const Curve enterCurve = Curves.easeOutCubic;

  /// How far an element travels up as it fades in, in logical pixels.
  static const double riseDistance = 28;

  /// One full revolution of the hero tech badges around the photo.
  ///
  /// Deliberately slow: at this speed the ring reads as ambient life. Anything
  /// under about 15s starts competing with the headline for attention.
  static const Duration orbitPeriod = Duration(seconds: 32);

  /// The whole hero cluster — photo, rings and badges — floating up and down.
  ///
  /// The period is deliberately not a factor of [orbitPeriod]: coprime-ish
  /// cycles take a long time to line up again, so the pair never settles into
  /// an obvious repeat.
  static const Duration heroFloatPeriod = Duration(milliseconds: 3200);
  static const double heroFloatDistance = 14;

  /// Boot sequence: the rule fills, then the panels part.
  ///
  /// Purely a brand moment — the actual load already happened behind the
  /// native window and the web loader — so these are a taste setting. Tune
  /// [introFill] to change how long the mark is held.
  static const Duration introFill = Duration(milliseconds: 1200);
  static const Duration introPart = Duration(milliseconds: 800);

  /// One half of the nav curtain wipe: the panel covers in this long, then
  /// retracts in the same again.
  static const Duration curtain = Duration(milliseconds: 420);

  /// Symmetric ease: the panel accelerates in and decelerates out, so cover
  /// and reveal read as one motion rather than two.
  static const Curve curtainCurve = Curves.easeInOutCubic;

  /// The point in a route transition where the curtain stops covering and
  /// starts retracting — the first frame the incoming page is actually seen.
  ///
  /// Content reveals must not start before this, or they play out behind the
  /// panel and the page arrives already settled.
  static const double curtainRevealPoint = 0.5;

  /// The per-line block wipe that carries text in, measured off the reference
  /// site: the panel takes [blockCover] to sweep across a line, then
  /// [blockReveal] to retract off the far edge and leave the text behind.
  ///
  /// Retracting is the longer half on purpose — covering is setup, uncovering
  /// is the part being watched.
  static const Duration blockCover = Duration(milliseconds: 500);
  static const Duration blockReveal = Duration(milliseconds: 700);

  /// The beat between the page curtain finishing and the line blocks starting,
  /// so the two wipes read as consecutive rather than as one smear.
  static const Duration blockGap = Duration(milliseconds: 300);

  /// Where [blockCover] ends on the combined 0..1 timeline.
  static const double blockCoverFraction = 500 / (500 + 700);

  /// Width of the rule in front of a project row's index number: narrow at
  /// rest, widened on hover/tap — the growth is what carries the number and
  /// title along with it. See `_RowLeaderLine` in `project_list_row.dart`.
  static const double rowLeaderIdleWidth = 44;
  static const double rowLeaderHoverWidth = 100;

  /// Nav tap -> section. Long enough to read as travel across the page,
  /// short enough not to feel sluggish on a seven-section scroll.
  static const Duration scrollToSection = Duration(milliseconds: 720);
  static const Curve scrollCurve = Curves.easeInOutCubic;

  /// Where the scroll-spy line sits, as a fraction of viewport height. A
  /// section becomes active once its top edge crosses this.
  static const double scrollSpyLine = 0.3;

  /// Fraction of the viewport height an element must cross before it reveals.
  /// 0.88 means it starts animating slightly before it is fully on screen.
  static const double revealThreshold = 0.88;

  /// One down-and-back cycle of the section header's scroll-cue chevron.
  static const Duration chevronBobPeriod = Duration(milliseconds: 1100);

  /// How far the chevron travels downward each cycle, in logical pixels.
  static const double chevronBobDistance = 8;

  /// Honours the OS "reduce motion" setting — animations become instant
  /// rather than being faked at a shorter duration.
  static bool reducedMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
