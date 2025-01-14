import 'package:flutter/material.dart';

class HeroPageRoute extends PageRouteBuilder {
  final Widget page;
  final String heroTag;

  HeroPageRoute({
    required this.page,
    required this.heroTag,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
} 