import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Material Design 3 Shared Axis Page Transition
/// Creates a horizontal shared axis transition between pages
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SharedAxisPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationConstants.durationMedium,
          reverseTransitionDuration: AnimationConstants.durationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}

/// Shared Axis Transition Widget
class SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Entering page
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    final slideIn = CurvedAnimation(
      parent: animation,
      curve: AnimationConstants.curveEmphasized,
    );

    // Exiting page (when this page is being replaced)
    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );
    final slideOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AnimationConstants.curveEmphasized,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeIn),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(slideIn),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.1, 0),
            ).animate(slideOut),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Fade Through Page Transition (M3 pattern for unrelated pages)
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeThroughPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationConstants.durationMedium,
          reverseTransitionDuration: AnimationConstants.durationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}

/// Fade Through Transition Widget
class FadeThroughTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const FadeThroughTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    final scaleIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );
    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    return FadeTransition(
      opacity: fadeIn,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(scaleIn),
          child: child,
        ),
      ),
    );
  }
}

/// Scale fade transition for dialogs and overlays
class ScaleFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleFadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationConstants.durationMedium,
          reverseTransitionDuration: AnimationConstants.durationShort,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: AnimationConstants.curveSpring,
              ),
            );
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            );
          },
        );
}

/// Extension to easily navigate with transitions
extension NavigatorTransitions on NavigatorState {
  Future<T?> pushSharedAxis<T>(Widget page) {
    return push(SharedAxisPageRoute<T>(page: page));
  }

  Future<T?> pushFadeThrough<T>(Widget page) {
    return push(FadeThroughPageRoute<T>(page: page));
  }

  Future<T?> pushScaleFade<T>(Widget page) {
    return push(ScaleFadePageRoute<T>(page: page));
  }
}
