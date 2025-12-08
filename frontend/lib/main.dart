import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:promillezone/constant.dart';
import 'package:promillezone/firebase_options.dart';
import 'package:promillezone/provider.dart';
import 'package:promillezone/route.dart';
import 'package:promillezone/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  if (!Platform.isLinux) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: appName,
        theme: darkTheme,
        routerConfig: routerConfig,
      ),
    );
  }
}
