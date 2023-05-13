import 'package:flutter/material.dart';

class SlideRoute extends PageRouteBuilder {
  SlideRoute(
      {required Widget page,
      Offset begin = const Offset(-1, 0),
      Offset end = Offset.zero})
      : super(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                        position: Tween<Offset>(begin: begin, end: end)
                            .animate(animation),
                        child: child));
}
