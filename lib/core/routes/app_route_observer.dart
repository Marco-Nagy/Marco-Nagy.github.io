import 'package:flutter/widgets.dart';

/// App-wide observer so a page can tell when another route has been pushed
/// on top of it, or when it has come back into view.
///
/// Used to pause looping media (a GIF screenshot) that Flutter otherwise
/// keeps animating for as long as its widget stays mounted — a project's
/// detail page stays mounted (and its GIFs keep decoding frames) under
/// whatever the admin pushes on top of it to edit, and that ongoing decode
/// is real CPU competing with the new route's own transition, which is what
/// reads as lag exactly when Edit is pressed.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
