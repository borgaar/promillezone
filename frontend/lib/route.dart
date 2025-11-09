import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:promillezone/feature/onboarding/page/welcome.dart';

final class RouteNames {
  static const welcome = "welcome";
}

final routerConfig = GoRouter(
  initialLocation: "/welcome",
  routes: [
    GoRoute(
      name: RouteNames.welcome,
      path: "/welcome",
      pageBuilder: (context, state) => MaterialPage(child: WelcomePage()),
    ),
  ],
);
