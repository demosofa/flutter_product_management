import 'package:flutter/widgets.dart';

class FadeRoute extends PageRouteBuilder {
  FadeRoute({required Widget page})
      : super(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
                      opacity: animation,
                      child: child,
                    ));
}
