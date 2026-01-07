import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:promillezone/feature/kiosk/page.dart';
import 'package:promillezone/feature/onboarding/page/welcome.dart';

final class RouteNames {
  static const welcome = "welcome";
  static const kiosk = "kiosk";
}

final routerConfig = GoRouter(
  initialLocation: "/welcome",
  routes: [
    GoRoute(
      name: RouteNames.welcome,
      path: "/welcome",
      pageBuilder: (context, state) => MaterialPage(child: WelcomePage()),
    ),
    GoRoute(
      path: "/kiosk",
      name: RouteNames.kiosk,
      pageBuilder: (context, state) => MaterialPage(child: KioskPage()),
    ),
  ],
  redirect: (context, state) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return "/kiosk";
    }
    return null;
  },
);
